require 'active_support'

module NinjaModel
  module SpawnMethods

    def merge(r)
      merged_relation = clone
      return merged_relation unless r
      return to_a & r if r.is_a?(Array)

      order_value = r.ordering
      if order_value.present?
        merged_relation.ordering = merged_relation.ordering + order_value
      end

      merged_predicates = @predicates + r.predicates

      unless @predicates.empty?
        seen = []
        merged_predicates = merged_predicates.reverse.reject { |w|
          nuke = false
          if w.respond_to?(:operator) && w.operator == :==
            attribute = w.attribute
            nuke = seen[attribute]
            seen[attribute] = true
          end
          nuke
        }.reverse
        merged_relation.predicates = merged_predicates
      end

      merged_relation

    end

    VALID_FIND_OPTIONS = [:conditions, :limit, :offset, :order]

    def apply_finder_options(options)
      relation = clone
      return relation unless options

      options.assert_valid_keys(VALID_FIND_OPTIONS)
      finders = options.dup
      finders.delete_if { |key, value| value.nil? }

      ([:order, :limit, :offset] & finders.keys).each do |finder|
        relation = relation.send(finder, finders[finder])
      end

      relation = relation.where(finders[:conditions]) if options.key?(:conditions)
      relation
    end
  end
end
