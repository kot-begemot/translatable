module Translatable
  class Base
    attr_reader :fields, :translation_model, :origin_key, :origin_reflection_name

    def initialize origin_model
      @origin_model = origin_model
    end

    # API 
    def field(*args)
      (@fields ||= []) << set_mapping(*args)
    end

    def class_name(model_name)
      @translation_model = prepare_model model_name
    end

    def foreign_key(key_name)
      @origin_key = key_name.to_sym
    end

    def reflection_name(reflection)
      @origin_reflection_name = reflection.to_sym
    end

    def locale_key(key_name, opts = {})
      set_mapping key_name, opts
      @locale_column = key_name.to_sym
    end

    # ACCESS
    def translation_model
      @translation_model || (@translation_model = prepare_model)
    end
    alias_method :t_model, :translation_model

    def origin_key
      @origin_key || (@origin_key = :origin_id)
    end

    def origin_reflection_name
      @origin_reflection_name || (@origin_reflection_name = :origin)
    end
    alias_method :or_name, :origin_reflection_name

    def locale_column
      @locale_column || (@locale_column = :locale)
    end

    def mapping
      unless @mapping_defined
        (@mapping ||= {})[locale_column] ||= :locale
        @mapping_defined = true
      end
      @mapping || {}
    end

    protected

    def set_mapping attribute, options = {}
      (@mapping ||= {})[attribute.to_sym] = options.delete(:as) || attribute rescue attribute
      return attribute, options
    end

    def origin_class_name
      @origin_model.name
    end

    def prepare_model(model_name = nil)
      model_constant = model_name ? model_name.to_s.camelize : "Translated#{origin_class_name}"
      model_constant.constantize
    end
  end
end