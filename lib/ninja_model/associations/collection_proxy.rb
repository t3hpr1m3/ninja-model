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

      def proxy_association
        @association
      end

      def respond_to?(name, include_private = false)
        super ||
          (load_target && target.respond_to?(name, include_private)) ||
          proxy_association.klass.respond_to?(name, include_private)
      end

      def method_missing(method, *args, &block)
        if target.respond_to?(method) || (!proxy_association.klass.respond_to?(method) && Class.respond_to?(method))
          if load_target
            if target.respond_to?(method)
              target.send(method, *args, &block)
            else
              begin
                super
              rescue NoMethodError => e
                raise e, e.message.sub(/ for #<.*$/, "via proxy for #{target}")
              end
            end
          end
        else
          scoped.send(method, *args, &block)
        end
      end
    end
  end
end
