module NinjaModel
  module Associations
    class BelongsToAssociation < AssociationProxy
      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
      end

      def replace(record)
        if record.nil?
          @target = @owner[@reflection.primary_key_name] = nil
        else
          @target = (AssociationProxy === record ? record.target : record)
          @owner[@reflection.primary_key_name] = record_id(record) if record.persisted?
          @updated = true
        end
        loaded
        record
      end

      private

      def find_target
        if @reflection.options[:primary_key]
          @reflection.klass.scoped.where( @reflection.options[:primary_key] => @owner.send(@reflection.primary_key_name)).first
        else
          @reflection.klass.scoped.where( :id => @owner.send(@reflection.primary_key_name)).first
        end
      end

      def record_id(record)
        record.send(@reflection.options[:primary_key] || :id)
      end

      def foreign_key_present
        !@owner[@reflection.primary_key_name].nil?
      end
    end
  end
end
