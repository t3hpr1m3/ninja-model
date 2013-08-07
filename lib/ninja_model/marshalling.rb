module NinjaModel
  module Marshalling
    extend ActiveSupport::Concern

    module InstanceMethods
      def marshal_dump
        ActiveSupport::JSON.encode(attributes)
      end

      def marshal_load(data)
        self.instantiate(ActiveSupport::JSON.decode(data))
      end
    end
  end
end
