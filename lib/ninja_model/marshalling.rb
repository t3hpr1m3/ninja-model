module NinjaModel
  module Marshalling
    extend ActiveSupport::Concern

    module InstanceMethods
      def marshal_dump
        h = self.instance_variables.inject({}) { |r, k|
          if k.to_s.eql?('@attributes')
            r[:attributes] = @attributes.inject({}) { |a, (k, v)|
              a[k] = ActiveSupport::JSON.encode(v)
              a
            }
          else
            r[k.to_s] = instance_variable_get(k)
          end
          r
        }
        h[:attributes] = {}
        @attributes.each do |k, v|
          h[:attributes][k] = ActiveSupport::JSON.encode(v)
        end
        ActiveSupport::JSON.encode(h)
      end

      def marshal_load(data)
        h = ActiveSupport::JSON.decode(data)
        @attributes = {}
        h.each do |k, v|
          if k.eql?(:attributes)
            @attributes[k] = ActiveSupport::JSON.decode(v)
          else
            instance_variable_set(k, v)
          end
        end
      end
    end
  end
end
