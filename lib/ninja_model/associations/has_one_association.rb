module NinjaModel
  module Associations
    class HasOneAssociation < AssociationProxy

      def create(attrs = {}, replace_existing = true)
        new_record
      end

      private

      def find_target
        @reflection.klass.scoped.where(@reflection.primary_key_name => @owner.send(:id)).first
      end

      def new_record(replace_existing)
      end
    end
  end
end
