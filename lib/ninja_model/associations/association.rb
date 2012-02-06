module NinjaModel
  module Associations
    class Association

      attr_reader :owner, :target, :reflection

      delegate :options, :to => :reflection

      def initialize(owner, reflection)
        @target = nil
        @owner, @reflection = owner, reflection

        reset
      end

      def reset
        @loaded = false
        @target = nil
      end

      def scoped
        target_scope.merge(association_scope)
      end

      def target_scope
        klass.scoped
      end

      def association_scope
        if klass
          @association_scope ||= AssociationScope.new(self).scope
        end
      end

      def klass
        reflection.klass
      end

      private

      def build_record(attributes, options)
        record = reflection.build_association(attributes, options) do |r|
          attrs = create_scope.except(*r.changed)
          r.assign_attributes(
            create_scope.except(*r.changed)
          )
        end
      end

      def creation_attributes
        if options[:through]
          raise NotImplementedError, "NinjaModel does not support through associations yet."
        else
          super
        end
      end
    end
  end
end
