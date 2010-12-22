module NinjaModel
  module Adapters
    class AdapterSpecification
      attr_accessor :config, :adapter_method

      def initialize(config, adapter_method)
        @config, @adapter_method = config, adapter_method
      end
    end
  end
end
