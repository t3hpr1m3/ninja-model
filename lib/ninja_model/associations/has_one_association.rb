module NinjaModel
  module Associations
    class HasOneAssociation < SingularAssociation

      def replace(record, save = true)
        raise_on_type_mismatch(record) if record
        load_target

        if target && target != record
          remove_target!(options[:dependent]) unless target.destroyed?
        end

        if record
          set_owner_attributes(record)
          set_inverse_instance(record)

          if owner.persisted? && save && !record.save
            nullify_owner_attributes(record)
            set_owner_attributes(target) if target
            raise RecordNotSaved, "Failed to save the new associated #{reflection.name}."
          end
        end

        self.target = record

      end

      def delete(method = options[:dependent])
        if load_target
          case method
          when :delete
            target.delete
          when :destroy
            target.destroy
          when :nullify
            target.update_attribute(reflection.foreign_key, nil)
          end
        end
      end

      private

      def set_new_record(record)
        replace(record, false)
      end

      def remove_target!(method)
        if method.in?([:delete, :destroy])
          target.send(method)
        else
          nullify_owner_attributes(target)

          if target.persisted? && owner.persisted? && !target.save
            set_owner_attributes(target)
            raise RecordNotSaved, "Failed to remove the existing associated #{reflection.name}.  The record failed to save when after its foreign key was set to nil."
          end
        end
      end

      def nullify_owner_attributes(record)
        record[reflection.foreign_key] = nil
      end
    end
  end
end
