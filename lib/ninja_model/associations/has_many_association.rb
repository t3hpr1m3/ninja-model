module NinjaModel
  module Associations
    class HasManyAssociation
      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        @relation = reflection.klass.scoped.where(reflection.primary_key_name.to_sym.eq(owner.id))
      end

      delegate :each, :collect, :map, :to_a, :size, :blank?, :empty?, :to => :relation

      def method_missing(method, *args)
        if @relation.respond_to?(method)
          @relation.send(method, *args)
        else
          super
        end
      end

      def relation
        @relation
      end

      def inspect
        @relation.to_a.inspect
      end

      def blank?
        @relation.blank?
      end

      def to_ary
        @relation.to_a
      end
    end
  end
end