require 'active_support'

module NinjaModel
  module SpawnMethods

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
