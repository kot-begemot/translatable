require "translatable/generator_helper"

module Translatable
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      include Translatable::GeneratorHelper

      desc "Creates ActiveRecord model and injects translatable block into it"

      class_option :translated_model, :type => :string, :desc => "Defines the model responsible for translations"
      class_option :origin,           :type => :string, :desc => "Defines the association name for translation record that deals with origin"
      class_option :locale,           :type => :string, :desc => "Defines the column for translation record that keeps the locale"

      def create_model
        self.attributes = attrs
        parse_attributes!
        invoke "active_record:model", [class_name], {migration: true, timestamps: true} unless model_exists?
      end

      # all public methods in here will be run in order
      def inject_translatable_block
        inject_into_class model_path, class_name, generate_translatable_block
      end

      protected

      def generate_translatable_block
        block = "  translatable do"
        attributes.each do |attr|
          block << "\n    field :#{attr.name}, :presence => true#, :uniqueness => true"
        end
        block << (options[:translated_model].nil? ?
            "\n    #class_name 'Translated#{class_name}'" :
            "\n    class_name '#{options[:translated_model]}'")
        block << (options[:origin].nil? ?
            "\n    #reflection_name :#{singular_table_name}" :
            "\n    reflection_name :#{options[:origin]}")
        block << "\n    #foreign_key :origin_id" 
        block << (options[:locale].nil? ?
            "\n    #locale_key :locale" :
            "\n    locale_key :#{options[:locale]}")
        block << "\n  end\n"

        block << "\n  #accepts_nested_attributes_for :translations, :current_translation"
        block << "\n  #attr_accessible :translations_attributes, :current_translation_attributes\n"
      end
    end
  end
end
