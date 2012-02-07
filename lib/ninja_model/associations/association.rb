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

      def reload
        reset
        reset_scope
        load_target
        self unless target.nil?
      end

      def loaded?
        @loaded
      end

      def loaded!
        @loaded = true
      end

      def stale_target?
        false
      end

      def target=(target)
        @target = target
        loaded!
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

      def reset_scope
        @association_scope = nil
      end

      def set_inverse_instance(record)
        if record && invertible_for?(record)
          inverse = record.association(inverse_reflection_for(record).name)
          inverse.target = owner
        end
      end

      def klass
        reflection.klass
      end

      def target_scope
        klass.scoped
      end

      def load_target
        if find_target?
          @target ||= find_target
        end
        loaded! unless loaded?
        target
      rescue NinjaModel::RecordNotFound
        reset
      end

      private

      def find_target?
        !loaded? && (!owner.new_record? || foreign_key_present?) && klass
      end

      def build_record(attributes, options)
        record = reflection.build_association(attributes, options) do |r|
          attrs = create_scope.except(*r.changed)
          r.assign_attributes(
            create_scope.except(*r.changed)
          )
        end
      end

      def creation_attributes
        attributes = {}
        if options[:through]
          raise NotImplementedError, "NinjaModel does not support through associations yet."
        else
          if reflection.macro.in?([:has_one, :has_many])
            attributes[reflection.foreign_key] = owner[reflection.ninja_model_primary_key]
            if reflection.options[:as]
              attributes[reflection.type] = owner.class.base_class.name
            end
          end
          attributes
        end
      end

      def set_owner_attributes(record)
        creation_attributes.each { |key, value| record[key] = value }
      end

      def foreign_key_present?
        false
      end

      def raise_on_type_mismatch(record)
        unless record.is_a?(reflection.klass) || record.is_a?(reflection.class_name.constantize)
          message = "#{reflection.class_name}(##{reflection.klass.object_id}) expected, got #{record.class}(##{record.class.object_id})"
          raise ActiveRecord::AssociationTypeMismatch, message
        end
      end

      def inverse_reflection_for(record)
        reflection.inverse_of
      end

      def invertible_for?(record)
        inverse_reflection_for(record)
      end

      def association_class
        @reflection.klass
      end
    end
  end
end
