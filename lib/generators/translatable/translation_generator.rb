module Translatable
  module Generators
    class TranslationGenerator < Rails::Generators::NamedBase
      attr_accessor :attributes
      argument :attrs, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      desc "Creates ActiveRecord model and injects translatable block into it"

      class_option :prefix, :type => :string, :default => "translatable", :desc => "Add indexes for references and belongs_to columns"
      class_option :origin, :type => :string, :default => "origin",       :desc => "Add indexes for references and belongs_to columns"
      class_option :locale, :type => :string, :default => "locale",       :desc => "Add indexes for references and belongs_to columns"

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
        unless attributes.empty?
        block << "  attr_accessible :#{attributes.map(&:name).join(", :")}\n"
      end
      block << "  #attr_protected :#{options[:origin]}_id, :#{options[:locale]}\n"
      block
    end

    def file_name
      "#{options[:prefix].downcase}_#{@file_name}"
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