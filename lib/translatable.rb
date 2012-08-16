require 'active_record'
require 'i18n'

module ActiveRecord
  ###
  # In order to made the model Translatable, an additional fields should
  # should be added first to it. Here is an example of it might be implemented:
  #
  # Examples:
  #
  #   class Author < ActiveRecord::Base
  #     validates :name, :presence => true
  #   end
  #
  #   class TranslatableNews < ActiveRecord::Base
  #     validates :title, :content, :presence => true
  #     validates :title, :uniqueness => true
  #
  #     attr_accessible :title, :content
  #   end
  #
  #   class News < ActiveRecord::Base
  #
  #     belongs_to  :author
  #
  #     is :translatable do
  #       translatable  :title
  #       translatable  :content
  #       translatable_model TranslatedNews
  #       translatable_origin :origin_id
  #     end
  #
  #     attr_accessible :author_id, :author
  #   end
  #
  # An example of application:
  #
  #   news = News.create :translations_attributes => [{title: "Resent News", content: "That is where the text goes", locale: "en"}]
  #   news.translations.create title: "Заголовок", content: "Содержание",locale: "ru"
  #
  #   news.content
  #   # => "That is where the text goes"
  #
  #   ::I18n.locale = "ru"
  #   news.content
  #   # => "Сюди идет текст"
  #
  #   ::I18n.locale = "de"
  #   news.content
  #   # => nil
  #
  #   ::I18n.locale = ::I18n.default_locale
  #   news.content
  #   # => "That is where the text goes"
  #
  module Translatable

    def translatable
      extend ActiveRecord::Translatable::ClassMethods
      include ActiveRecord::Translatable::InstanceMethods

      translatable_define_hash
      yield
      translatable_register
    end

    module ClassMethods

      protected

      ###
      # Fields that are translatable.
      # Those fields should be defined in the original model including all the related params.
      # Examples:
      #
      #   translatable_property  :title,    String,   required: true, unique: true
      #   translatable_property  :content,  Text
      #
      # NB! Will raise an error if there was no fields specified
      #
      def translatable *args
        (@translatable[:properties] ||= [])  << args
      end

      ###
      # Defines model that will be treated as translation handler.
      # Model can be defined as String, Symbol or Constant.
      # Examples:
      #
      #   translated_model TranslatedNews
      #   translated_model "TranslatedNews"
      #   translated_model :TranslatedNews
      #
      # Default: Translatable<ModelName>
      #
      def translatable_model model_name
        @translatable[:model] = translatable_model_prepared model_name
      end

      ###
      # Define the key that the translation will be used for belongs_to association,
      # to communicate with original model
      # Example:
      #
      #   translatable_origin :news
      #
      # Default: :origin
      #
      def translatable_origin origin_key
        @translatable[:origin] = translatable_origin_prepared origin_key
      end

      ###
      # Define the key that the translation will be used for belongs_to association,
      # to communicate with original model
      # Example:
      #
      #   translatable_origin :language
      #
      # Default: :locale
      #
      def translatable_locale locale_attr
        @translatable[:locale] = translatable_locale_prepared locale_attr
      end

      ###
      # Returns Model as a constant that deals with translations
      def translatable_model_prepared model_name = nil
        model_constant = model_name
        model_constant ||= "Translatable#{self.name}"
        model_constant.to_s.constantize
      end


      def translatable_origin_prepared origin_key = nil
        origin_key || "origin"
      end

      def translatable_locale_prepared locale = nil
        locale || "locale"
      end

      ###
      # Define hash that contains all the translations
      def translatable_define_hash
        @translatable = {}
      end

      ###
      # Handles all the registring routine, defining methods,
      # properties, and everything else
      def translatable_register
        raise ArgumentError.new("At least one property should be defined") if [nil, []].include?(@translatable[:properties])
        [:model,:origin,:locale].each { |hash_key| @translatable[hash_key] ||= send "translatable_#{hash_key}_prepared" }

        translatable_register_properties_for_origin
        translatable_register_properties_for_translatable
      end

      ###
      # Handle the routine to define all th required stuff on the original maodel
      def translatable_register_properties_for_origin
        has_many :translations, :class_name => @translatable[:model].name, :foreign_key => :"#{@translatable[:origin]}_id"
        accepts_nested_attributes_for :translations
        attr_accessible :translations_attributes

        @translatable[:properties].each do |p|
          self.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{p.first}
              current_translation.try(:#{p.first})
            end
          RUBY
        end

        self.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def current_translation
            if translatable_locale_changed?
              @translatable_locale = ::I18n.locale.to_s
              @current_translation = translations.where(:#{@translatable[:locale]} => @translatable_locale).first
            end
            @current_translation
          end
          protected :current_translation
        RUBY
      end

      def translatable_register_properties_for_translatable
        @translatable[:model].module_eval <<-RUBY, __FILE__, __LINE__ + 1
          validates :#{@translatable[:locale]}, :presence => true
          validates :#{@translatable[:locale]}, :uniqueness => { :scope => :#{@translatable[:origin]}_id }

          belongs_to :#{@translatable[:origin]}, :class_name => "#{self.name}"

          attr_accessible :#{@translatable[:locale]}, :#{@translatable[:origin]}_id
        RUBY
      end
    end

    module InstanceMethods

      protected

      def translatable_locale_changed?
        @translatable_locale.to_s != ::I18n.locale.to_s
      end
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::Translatable