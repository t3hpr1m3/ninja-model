module NinjaModel
  module Associations
    class AssociationScope

      attr_reader :association

      delegate :klass, :owner, :reflection, :to => :association
      delegate :chain, :conditions, :options, :ninja_model, :active_record, :to => :reflection

      def initialize(association)
        @association = association
      end

      def scope
        scope = klass.unscoped
        scope = scope.extending(*Array.wrap(options[:extend]))
        scope = scope.apply_finder_options(
          options.slice(
            :order, :limit, :joins, :group, :having, :offset
          )
        )

        add_constraints(scope)
      end

      def add_constraints(scope)
        if reflection.source_macro == :belongs_to
          key = reflection.association_primary_key
          foreign_key = reflection.foreign_key
        else
          key = reflection.foreign_key
          foreign_key = reflection.active_record_primary_key
        end

        scope = scope.where(key => owner[foreign_key])
      end
    end
  end
end
