require 'active_support'

module NinjaModel
  module QueryMethods
    extend ActiveSupport::Concern

    def order(*args)
      relation = clone
      relation.ordering += args.flatten unless args.blank?
      relation
    end

    def where(opts, *rest)
      relation = clone
      relation.predicates += build_predicates(opts, rest)
      relation
    end

    def limit(value)
      relation = clone
      relation.limit_value = value
      relation
    end

    private

    def build_predicates(opts, other = [])
      case opts
      when String
        raise ArgumentError,
          "NinjaModel doesn't work with strings...yet. You'll need to use a predicate (see NinjaModel::Predicate::PREDICATES for a list)."
      when Array
        opts.collect do |o|
          build_predicates(o)
        end.flatten!
      when Hash
        opts.to_a.map do |o|
          raise ArgumentError, "Not sure what to do with #{o}" unless o.length.eql?(2)
          k = o[0]
          v = o[1]

          case k
          when NinjaModel::Predicate
            k.value = v
            k
          when Symbol
            raise ArgumentError, "#{klass} doesn't have an attribute #{k}." unless klass.model_attributes.with_indifferent_access.key?(k)
            p = NinjaModel::Predicate.new(k, :eq)
            p.value = v
            p
          else
            raise ArgumentError, "#{k} isn't a predicate or a symbol."
          end
        end
      else
        raise ArgumentError, "Unknown argument to #{self}.where: #{opts.inspect}"
      end
    end
  end
end
