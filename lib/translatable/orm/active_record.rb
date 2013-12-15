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
      t_register_locale
    end

    module ClassMethods

      protected

      ###
      # Handle the routine to define all th required stuff on the original maodel
      def t_register_origin
        has_many :translations, 
          :class_name => @translatable_base.translation_model.to_s, 
          :foreign_key => @translatable_base.origin_key,
          :dependent => :destroy

        has_one :current_translation, 
          :conditions => proc { ["#{t_locale_column} = ?", ::I18n.locale] },
          :class_name => @translatable_base.translation_model.to_s, 
          :foreign_key => @translatable_base.origin_key,
          :inverse_of =>  @translatable_base.or_name
      end

      def t_register_translations
        @translatable_base.tap do |t|
          t.t_model.validates t.locale_column, :presence => true
          t.t_model.validates t.locale_column, :uniqueness => { :scope => t.origin_key }
          t.t_model.validates t.locale_column, :format => {:with => /[a-z]{2}/}, :unless => Proc.new {
            |record| record.public_send(t.locale_column).blank?
          }

          t.t_model.belongs_to t.or_name, :class_name => self.name, :inverse_of => :current_translation

          t.fields.each do |f|
            t.t_model.validates(f.first, f.last) unless f[1].blank?
          end
        end
      end

      def t_register_locale
        @translatable_base.mapping.each_pair do |attr, attr_alias| 
          self.instance_eval do
            define_method attr_alias do 
              current_translation.try(attr)
            end
          end
        end
      end
    end

    module InstanceMethods
      def other_translations
        translations - [current_translation]
      end

      def t(locale)
        translations.select { |t| t.send(t_locale_column) == locale.to_s }.first
      end

      def with_locale(locale, &block)
        begin
          set_current_translation locale.to_sym
          result = block.arity > 0 ? block.call(self) : yield
        ensure
          set_current_translation
        end
        result
      end

      def t_set_current(locale = ::I18n.locale)
        translations.load_target unless translations.loaded?
        association(:current_translation).target = t(locale.to_s)
      end
      alias_method :set_current_translation, :t_set_current

      protected

      def t_locale_column
        self.class.instance_variable_get(:@translatable_base).locale_column
      end
    end
  end
end