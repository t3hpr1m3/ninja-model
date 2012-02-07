module NinjaModel
  module Associations
    class BelongsToAssociation < SingularAssociation

      def replace(record)
        raise_on_type_mismatch(record) if record

        replace_keys(record)

        @updated = true if record

        self.target = record
      end

      def updated?
        @updated
      end

      private

      def find_target?
        !loaded? && foreign_key_present? && klass
      end

      def different_target?(record)
        record.nil? && owner[reflection.foreign_key] ||
          record && record.id != owner[reflection.foreign_key]
      end

      def replace_keys(record)
        if record
          owner[reflection.foreign_key] = record[reflection.association_primary_key(record.class)]
        else
          owner[reflection.foreign_key] = nil
        end
      end

      def foreign_key_present?
        owner[reflection.foreign_key]
      end

      def target_id
        if options[:primary_key]
          owner.send(reflection.name).try(:id)
        else
          owner[reflection.foreign_key]
        end
      end
    end
  end
end
