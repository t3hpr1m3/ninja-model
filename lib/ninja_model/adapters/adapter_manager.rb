module NinjaModel
  module Adapters
    class AdapterManager
      attr_reader :adapter_pools

      def initialize(pools = {})
        @adapter_pools = pools
      end

      def create_adapter(name, spec)
        @adapter_pools[name] = Adapters::AdapterPool.new(spec)
      end

      def release_active_adapters!
        @adapter_pools.each_value do |pool|
          pool.release_adapter
        end
      end

      def release_reloadable_adapters!
        @adapter_pools.each_value do |pool|
          pool.shutdown_reloadable_adapters!
        end
      end

      def release_all_adapters!
        @adapter_pools.each_value do |pool|
          pool.shutdown!
        end
      end

      def retrieve_adapter(klass)
        pool = retrieve_adapter_pool(klass)
        (pool && pool.instance) or raise StandardError
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
        unless env.key?('rask.test')
          NinjaModel::Base.clear_active_instances!
        end
      end
    end
  end
end
