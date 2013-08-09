module NinjaModel
  module Marshalling
    extend ActiveSupport::Concern

    module InstanceMethods
      def marshal_dump
        exceptions = %w(@association_cache @aggregation_cache @attributes)
        h = self.instance_variables.inject({}) { |r, k|
          unless exceptions.include?(k.to_s)
            r[k.to_s] = instance_variable_get(k)
          end
          r
        }
        h['@attributes'] = @attributes.inject({}) { |a, (k, v)|
          a[k] = ActiveSupport::JSON.encode(v)
          a
        }
        ActiveSupport::JSON.encode(h)
      end

      def marshal_load(data)
        h = ActiveSupport::JSON.decode(data)
        h.each do |k, v|
          instance_variable_set(k, v)
        end
        @association_cache = {}
        @aggregation_cache = {}
      end
    end
  end
end
