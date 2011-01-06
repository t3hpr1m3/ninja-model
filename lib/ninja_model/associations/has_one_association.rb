module NinjaModel
  module Associations
    class HasOneAssociation < AssociationProxy
      def initialize(owner, reflection)
        super
      end

      def create(attrs = {}, replace_existing = true)
        new_record
      end

      private

      def new_record(replace_existing)
      end
    end
  end
end
