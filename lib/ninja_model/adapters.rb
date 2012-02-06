module NinjaModel
  class AdapterNotSpecified < StandardError; end
  class InvalidAdapter < StandardError; end
  class InvalidSpecification < StandardError; end

  module Adapters
    extend ActiveSupport::Concern

    autoload :AbstractAdapter, 'ninja_model/adapters/abstract_adapter'
    autoload :AdapterManager, 'ninja_model/adapters/adapter_manager'
    autoload :AdapterPool, 'ninja_model/adapters/adapter_pool'
    autoload :AdapterSpecification, 'ninja_model/adapters/adapter_specification'

    included do
      class_attribute :adapter_manager
      self.adapter_manager = NinjaModel::Adapters::AdapterManager.new
    end

    def adapter
      self.class.retrieve_adapter
    end

    module ClassMethods
      def register_adapter(name, klass)
        if klass.ancestors.include?(NinjaModel::Adapters::AbstractAdapter)
          Adapters::AdapterManager.register_adapter_class(name, klass)
        else
          raise InvalidAdapter, "Invalid adapter: #{klass}"
        end
      end

      def set_adapter(spec = nil)
        case spec
        when nil
          raise AdapterNotSpecified unless defined?(Rails.env)
          set_adapter(Rails.env)
        when Symbol, String
          if config = NinjaModel.configuration.specs[spec.to_s]
            set_adapter(config)
          else
            raise InvalidSpecification, "#{spec} is not configured"
          end
        when Adapters::AdapterSpecification
          self.adapter_manager.create_adapter(name, spec)
        else
          spec = spec.symbolize_keys
          raise AdapterNotSpecified, "configuration does not specify adapter: #{spec}" unless spec.key?(:adapter)
          adapter_name = spec[:adapter]
          raise InvalidAdapter, "configuration does not specify adapter" unless Adapters::AdapterManager.registered?(adapter_name)
          shutdown_adapter
          set_adapter(Adapters::AdapterSpecification.new(spec, adapter_name))
        end
      end

      def retrieve_adapter
        adapter_manager.retrieve_adapter(self)
      end
      alias :adapter :retrieve_adapter

      def shutdown_adapter(klass = self)
        adapter_manager.remove_adapter(klass)
      end
    end
  end
end
