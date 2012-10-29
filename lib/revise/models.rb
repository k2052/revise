module Revise
  module Models
    class MissingAttribute < StandardError
      def initialize(attributes)
        @attributes = attributes
      end

      def message
        "The following attribute(s) is (are) missing on your model: #{@attributes.join(", ")}"
      end
    end

    def self.config(mod, *accessors)
      class << mod; attr_accessor :available_configs; end
      mod.available_configs = accessors

      accessors.each do |accessor|
        mod.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{accessor}
            if defined?(@#{accessor})
              @#{accessor}
            elsif superclass.respond_to?(:#{accessor})
              superclass.#{accessor}
            else
              Revise.#{accessor}
            end
          end

          def #{accessor}=(value)
            @#{accessor} = value
          end
        METHOD
      end
    end

    def self.check_fields!(klass)
      failed_attributes = []
      instance = klass.new

      klass.revise_modules.each do |mod|
        constant = const_get(mod.to_s.classify)

        if constant.respond_to?(:required_fields)
          constant.required_fields(klass).each do |field|
            failed_attributes << field unless instance.respond_to?(field)
          end
        else
          ActiveSupport::Deprecation.warn "The module #{mod} doesn't implement self.required_fields(klass). " \
            "Devise uses required_fields to warn developers of any missing fields in their models. " \
            "Please implement #{mod}.required_fields(klass) that returns an array of symbols with the required fields."
        end
      end

      if failed_attributes.any?
        fail Revise::Models::MissingAttribute.new(failed_attributes)
      end
    end
    
    def revise(*modules)
      options = modules.extract_options!.dup

      plural_name = self.model_name.plural.to_sym
      Revise::MODULES[plural_name] = []

      revise_modules_hook! do
        include Revise::Models::Authenticatable

        modules.each do |m|
          mod = Revise::Models.const_get(m.to_s.classify)

          if mod.const_defined?("ClassMethods")
            class_mod = mod.const_get("ClassMethods")
            extend class_mod

            if class_mod.respond_to?(:available_configs)
              available_configs = class_mod.available_configs
              available_configs.each do |config|
                next unless options.key?(config)
                send(:"#{config}=", options.delete(config))
              end
            end
          end

          include mod

          Revise::MODULES[plural_name] << m.to_s.classify
        end

        options.each { |key, value| send(:"#{key}=", value) }
      end
    end

    def revise_modules_hook!
      yield
    end
  end
end

require 'revise/models/authenticatable'
