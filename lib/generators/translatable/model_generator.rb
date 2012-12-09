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
          block << "\n    translatable :#{attr.name}, :presence => true#, :uniqueness => true"
        end
        block << (options[:translated_model].nil? ?
            "\n    #translatable_model 'Translated#{class_name}'" :
            "\n    translatable_model '#{options[:translated_model]}'")
        block << (options[:origin].nil? ?
            "\n    #translatable_origin :#{singular_table_name}" :
            "\n    translatable_origin :#{options[:origin]}")
        block << (options[:locale].nil? ?
            "\n    #translatable_locale :locale" :
            "\n    translatable_locale :#{options[:locale]}")
        block << "\n  end\n"
      end
    end
  end
end
