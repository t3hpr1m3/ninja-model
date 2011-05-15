module NinjaModel

  module Adapters
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    class AdapterNotSpecified < StandardError; end
    class InvalidAdapter < StandardError; end
    class InvalidSpecification < StandardError; end

    autoload :AdapterSpecification
    autoload :AdapterManager
    autoload :AdapterPool
    autoload :AbstractAdapter
  end

  class Base
    class_attribute :adapter_manager
    self.adapter_manager = NinjaModel::Adapters::AdapterManager.new

    def adapter
      self.class.retrieve_adapter
    end

    class << self
      def register_adapter(name, klass)
        Adapters::AdapterManager.register_adapter_class(name, klass)
      end

      def set_adapter(spec = nil)
        case spec
        when nil
          raise Adapters::AdapterNotSpecified unless defined?(Rails.env)
          set_adapter(Rails.env)
        when Adapters::AdapterSpecification
          self.adapter_manager.create_adapter(name, spec)
        when Symbol, String
          if config = NinjaModel.configuration.specs[spec.to_s]
            set_adapter(config)
          else
            raise Adapters::InvalidSpecification, "#{spec} is not configured"
          end
        else
          spec = spec.symbolize_keys
          puts "spec: #{spec.inspect}"
          raise Adapters::AdapterNotSpecified, "configuration does not specify adapter" unless spec.key?(:adapter)
          adapter_name = spec[:adapter]
          raise Adapters::InvalidAdapter, "configuration does not specify adapter" unless Adapters::AdapterManager.registered?(adapter_name)
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
