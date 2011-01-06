module NinjaModel
  module Adapters
    class AbstractAdapter
      class << self
        def instance
          @instance ||= new
        end
      end

      def initialize(config, logger = nil)
        @active = nil
        @config, @logger = config, logger
      end

      def adapter_name
        'Abstract'
      end

      def persistent_connection?
        true
      end

      def active?
        @active != false
      end

      def reconnect!
        @active = true
      end

      def disconnect!
        @active = false
      end

      def reset!
      end

      def verify!
        reconnect! unless active?
      end

      def create(model)
        false
      end

      def read(query)
        nil
      end

      def update(model)
        false
      end

      def delete(model)
        false
      end

      def raw_connection
        @connection
      end
    end
  end
end
