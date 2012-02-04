module NinjaModel
  module Associations
    class HasManyAssociation
      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        @relation = apply_default_scope(reflection.klass.scoped)
      end

      delegate :each, :collect, :map, :to_a, :size, :blank?, :empty?, :to => :relation

      def method_missing(method, *args)
        if @relation.respond_to?(method)
          @relation.send(method, *args)
        elsif @relation.klass.respond_to?(method)
          apply_default_scope(@relation.klass.scoped).send(method, *args)
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

      def replace(other_array)
        @current = other_array
      end

      def blank?
        @relation.blank?
      end

      def to_ary
        @relation.to_a
      end

      private

      def apply_default_scope(scoping)
        scoping.where(@reflection.primary_key_name.to_sym.eq(@owner.id))
      end
    end
  end
end
