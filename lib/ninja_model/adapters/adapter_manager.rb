module NinjaModel
  module Adapters
    class AdapterManager

      class_attribute :registered
      self.registered = {}

      class << self
        def registered?(name)
          registered.key?(name.to_sym)
        end

        def register_adapter_class(name, klass)
          registered[name.to_sym] = klass
        end
      end

      attr_reader :adapter_pools

      def initialize(pools = {})
        @adapter_pools = pools
        @registered = {}
      end

      def create_adapter(name, spec)
        @adapter_pools[name] = Adapters::AdapterPool.new(spec)
      end

      def release_active_adapters!
        @adapter_pools.each_value do |pool|
          pool.release_instance
        end
      end

      def release_all_adapters!
        @adapter_pools.each_value do |pool|
          pool.shutdown!
        end
      end

      def retrieve_adapter(klass)
        pool = retrieve_adapter_pool(klass)
        (pool && pool.instance) or raise StandardError, "Pool is empty or instance is null"
      end

      def remove_adapter(klass)
        pool = @adapter_pools[klass.name]
        return nil unless pool
        @adapter_pools.delete_if { |key, value| value == pool }
        pool.shutdown!
        pool.spec.config
      end

      def retrieve_adapter_pool(klass)
        pool = @adapter_pools[klass.name]
        return pool if pool
        return nil if NinjaModel::Base == klass
        retrieve_adapter_pool klass.superclass
      end
    end

    class AdapterManagement
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      ensure
        unless env.key?('rack.test')
          NinjaModel::Base.adapter_manager.release_active_adapters!
        end
      end
    end
  end
end
