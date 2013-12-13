require "translatable/generator_helper"

module Translatable
  module Generators
    class TranslationGenerator < Rails::Generators::NamedBase
      include Translatable::GeneratorHelper

      desc "Creates ActiveRecord for translation"

      class_option :prefix, :type => :string, :default => "translated", :desc => "Specifies the prefix to used tof translation dealer (Default: translatable)"
      class_option :origin, :type => :string, :default => "origin",       :desc => "Specifies the association name to be use for origin (Default: origin)"
      class_option :locale, :type => :string, :default => "locale",       :desc => "Specifies the column to be use for locale (Default: locale)"

      def create_model
        self.attributes = attrs
        parse_attributes!
        invoke "active_record:model", [class_name] + attrs + ["#{options[:origin]}_id:integer:true", "#{options[:locale]}:string"], {migration: true, timestamps: true} unless model_exists?
      end

      # all public methods in here will be run in order
      def inject_translatable_block
        inject_into_class model_path, class_name, generate_translatable_block
      end

      protected

      def generate_translatable_block
        block = <<CONTENT
  # This class deals purely with translations themselves. Hence, any edition of
  # should be avoided.
  # In later gem version its existance might not be necessary.
CONTENT
        # unless attributes.empty?
        #   block << "  attr_accessible :#{attributes.map(&:name).join(", :")}\n"
        # end
        block << "  #attr_protected :#{options[:origin]}_id, :#{options[:locale]}\n"
        block
      end

      def file_name
        "#{options[:prefix].downcase}_#{@file_name}"
      end
    end
  end
end