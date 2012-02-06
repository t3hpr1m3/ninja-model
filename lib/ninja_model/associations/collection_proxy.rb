module NinjaModel
  module Associations
    class CollectionProxy

      delegate :order, :limit, :where, :to => :scoped

      delegate :target, :load_target, :loaded?, :scoped, :to => :@association

      delegate :select, :find, :first, :last, :build, :create, :create,
        :count, :size, :length, :empty?, :any?, :to => :@association

      def initialize(association)
        @association = association
      end

      def method_missing(method, *args, &block)
        scoped.send(method, *args, &block)
      end
    end
  end
end
