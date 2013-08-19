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
          a[k] = read_attribute(k)
          a
        }
        begin
          res = ActiveSupport::JSON.encode(h)
        rescue IOError => ex
          pp ex.backtrace
        end
        res
      end

      def marshal_load(data)
        h = ActiveSupport::JSON.decode(data)
        h.each do |k, v|
          if k.eql?('@attributes')
            @attributes = {}
            v.each do |n, x|
              write_attribute(n, x)
            end
          else
            instance_variable_set(k, v)
          end
        end

        @association_cache = {}
        @aggregation_cache = {}
      end
    end
  end
end
