require 'active_support'

module NinjaModel

  module Adapters
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :AdapterSpecification
    autoload :AdapterManager
    autoload :AdapterPool
    autoload :AbstractAdapter

    class << self
    end
  end

  class Base
    class_attribute :adapter_manager
    self.adapter_manager = NinjaModel::Adapters::AdapterManager.new

    def adapter
      self.class.adapter
    end

    def self.set_adapter(spec = nil)
      case spec
      when nil
        raise AdapterNotSpecified unless defined?(Rails.env)
        set_adapter(Rails.env)
      when AdapterSpecification
        self.adapter_manager.create_adapter(name, spec)
      when Symbol, String
        if config = NinjaModel.configuration.specs[spec.to_s]
          set_adapter(config)
        else
          raise AdapterNotSpecified, "#{spec} is not configured"
        end
      else
        spec = spec.symbolize_keys
        unless spec.key?(:adapter) then raise AdapterNotSpecified, "configuration does not specify adapter" end
        begin
          require File.join(NinjaModel.configuration.adapter_path, "#{spec[:adapter]}_adapter")
        rescue LoadError => e
          raise "Please install (or create) the #{spec[:adapter]} adapter.  Search path is #{NinjaModel.configuration.adapter_path}"
        end
        adapter_method = "#{spec[:adapter]}_adapter"
        if !respond_to?(adapter_method)
          raise AdapterNotFound, "ninja configuration specifies nonexistent #{spec[:adapter]} adapter"
        end
        shutdown_adapter
        set_adapter(AdapterSpecification.new(spec, adapter_method))
      end
    end

    class << self
      def adapter
        retrieve_adapter
      end

      def retrieve_adapter
        adapter_manager.retrieve_adapter(self)
      end

      def shutdown_adapter(klass = self)
        adapter_manager.remove_adapter(klass)
      end
    end
  end
end
