module Translatable
  module GeneratorHelper
    def self.included(base)
      base.class_eval do
        attr_accessor :attributes
        argument :attrs, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
      end
    end

    protected

    def model_path
      File.join(destination_root, 'app/models', class_path, "#{file_name}.rb")
    end

    def model_exists?
      File.exists?(model_path)
    end
  end
end