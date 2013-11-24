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
  #       attribute  :title, :presence => true, :uniqueness => true
  #       attribute  :content, :presence => true
  #       model "TranslatedNews"
  #       foreign_key :origin_id
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

    def translatable(&block)
      extend Translatable::ActiveRecord::ClassMethods
      include Translatable::ActiveRecord::InstanceMethods

      @translatable_base = Translatable::Base.new(self)

      @translatable_base.instance_eval(&block)
      t_register_origin
      t_register_translations
    end

    module ClassMethods

      protected

      ###
      # Handle the routine to define all th required stuff on the original maodel
      def t_register_origin
        has_many :translations, 
          :class_name => @translatable_base.translation_model.to_s, 
          :foreign_key => @translatable_base.origin_key,
          :inverse_of =>  @translatable_base.or_name
        
        accepts_nested_attributes_for :translations
        attr_accessible :translations_attributes

        @translatable_base.fields.each do |p| 
          access_name = p[1].delete(:as) || p.first rescue p.first

          self.instance_eval do
            define_method access_name do 
              current_translation.try(p.first)
            end
          end
        end
      end

      def t_register_translations
        @translatable_base.tap do |t|
          t.t_model.validates t.locale_column, :presence => true
          t.t_model.validates t.locale_column, :uniqueness => { :scope => t.origin_key }
          t.t_model.validates t.locale_column, :format => {:with => /[a-z]{2}/}, :unless => Proc.new {
            |record| record.public_send(t.locale_column).blank?
          }

          t.t_model.belongs_to t.or_name, :class_name => self.name, :inverse_of => :translations

          t.fields.each do |f|
            t.t_model.validates(f.first, f.last) unless f[1].blank?
          end
        end
      end
    end

    module InstanceMethods
      def current_translation
        update_current_translation unless @translatable_locale
        @current_translation
      end

      def other_translations
        translations - [current_translation]
      end

      def t(locale)
        translations.select { |t| t.send(t_locale_column) == locale.to_s }.first
      end

      def with_locale(locale, &block)
        begin
          set_current_translation locale.to_sym
          result = block.arity > 0 ? block.call(self) : instance_eval(&block)
        ensure
          update_current_translation
        end
        result
      end

      def t_set_current(locale = ::I18n.locale)
        @translatable_locale = locale.to_s
        translations.load_target unless translations.loaded?
        @current_translation = t(locale)
      end
      alias_method :set_current_translation, :t_set_current

      protected

      def update_current_translation
        t_set_current(@translatable_locale = ::I18n.locale.to_s)
      end

      def t_locale_column
        self.class.instance_variable_get(:@translatable_base).locale_column
      end
    end
  end
end