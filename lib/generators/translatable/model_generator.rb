module Translatable
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      attr_accessor :attributes
      argument :attrs, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      desc "Creates ActiveRecord model and injects translatable block into it"

      class_option :translated_model, :type => :string, :desc => "Add indexes for references and belongs_to columns"
      class_option :origin,           :type => :string, :desc => "Add indexes for references and belongs_to columns"
      class_option :locale,           :type => :string, :desc => "Add indexes for references and belongs_to columns"

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

      def model_path
        File.join(destination_root, 'app/models', class_path, "#{file_name}.rb")
      end

      def model_exists?
        File.exists?(model_path)
      end
    end
  end
end
