require 'active_record'
require 'i18n'

module Translatable
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
  #   class TranslatableNews < ActiveRecord::Base  #
  #     attr_accessible :title, :content
  #   end
  #
  #   class News < ActiveRecord::Base
  #
  #     belongs_to  :author
  #
  #     translatable do
  #       translatable  :title, :presence => true, :uniqueness => true
  #       translatable  :content, :presence => true
  #       translatable_model "TranslatedNews"
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
  module ActiveRecord

    def translatable
      extend Translatable::ActiveRecord::ClassMethods
      include Translatable::ActiveRecord::InstanceMethods

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
      # Will not register the attributes as accessible.
      # IMPORTANT: Translatable block will be evaluated on the model after it
      # was loaded, so it will modify certain thing on final version. Hence this thing is needed.
      # Examples:
      #
      #   translatable_attr_protected
      #
      # Default: false
      #
      def translatable_attr_protected
        @translatable[:attr_accessible] = false
      end

      ###
      # Will not register the attributes as accessible.
      # IMPORTANT: Translatable block will be evaluated on the model after it
      # was loaded, so it will modify certain thing on final version. Hence this thing is needed.
      # Examples:
      #
      #   translatable_attr_protected
      #
      # Default: false
      #
      def translatable_attr_accessible
        @translatable[:attr_accessible] = true
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
          accessible_as = (p.last.delete(:as) || p.first rescue p.first)
          self.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{accessible_as}
              current_translation.try(:#{p.first})
            end
          RUBY
        end

        self.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def translatable_set_current
            @current_translation = translations.where(:#{@translatable[:locale]} => @translatable_locale).first
          end
          protected :translatable_set_current
        RUBY
      end

      def translatable_register_properties_for_translatable
        @translatable[:model].module_eval <<-RUBY, __FILE__, __LINE__ + 1
          validates :#{@translatable[:locale]}, :presence => true
          validates :#{@translatable[:locale]}, :format => { :with => /[a-z]{2}/}, :if => Proc.new {|record| !record.#{@translatable[:locale]}.blank? }
          validates :#{@translatable[:locale]}, :uniqueness => { :scope => :#{@translatable[:origin]}_id }

          belongs_to :#{@translatable[:origin]}, :class_name => "#{self.name}"
        RUBY

        unless @translatable[:attr_accessible].nil?
          @translatable[:model].module_eval <<-RUBY, __FILE__, __LINE__ + 1
            attr_#{!!@translatable[:attr_accessible] ? "accessible" : "protected" } :#{@translatable[:locale]}, :#{@translatable[:origin]}_id
          RUBY
        end

        @translatable[:properties].each do |p|
          if p.size > 1
            @translatable[:model].module_eval <<-RUBY, __FILE__, __LINE__ + 1
              validates :#{p.first}, #{p.last.inspect}
            RUBY
          end
        end
      end
    end

    module InstanceMethods

      def current_translation
        if translatable_locale_changed?
          @translatable_locale = ::I18n.locale.to_s
          translatable_set_current
        end
        @current_translation
      end

      def other_translations
        translations - [current_translation]
      end

      protected
      
      def translatable_locale_changed?
        @translatable_locale.to_s != ::I18n.locale.to_s
      end
    end
  end
end