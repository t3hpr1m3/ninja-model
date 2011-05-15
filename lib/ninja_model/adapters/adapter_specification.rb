module NinjaModel
  module Adapters
    class AdapterSpecification
      attr_reader :config, :name

      def initialize(config, name)
        @config, @name = config, name
      end
    end
  end
end
