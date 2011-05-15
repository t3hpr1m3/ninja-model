require 'active_record/associations/association_proxy'

module NinjaModel
  module Associations
    class AssociationProxy
      alias_method :proxy_respond_to?, :respond_to?
      alias_method :proxy_extend, :extend
      delegate :to_param, :to => :proxy_target
      instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to_missing|proxy_/ }

      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        @updated = false
        Array.wrap(reflection.options[:extend]).each { |ext| proxy_extend(ext) }
        reset
      end

      def proxy_owner
        @owner
      end

      def proxy_reflection
        @reflection
      end

      def proxy_target
        @target
      end

      def respond_to?(*args)
        proxy_respond_to?(*args) || (load_target && @target.respond_to?(*args))
      end

      def ===(other)
        load_target
        other === @target
      end

      def reload
        reset
        load_target
        self unless @target.nil?
      end

      def reset
        @loaded = false
        @target = nil
      end

      def loaded?
        @loaded
      end

      def loaded
        @loaded = true
      end

      def target
        @target
      end

      def target=(target)
        @target = target
        loaded
      end

      def inspect
        load_target
        @target.inspect
      end

      def send(method, *args)
        if proxy_respond_to?(method)
          super
        else
          load_target
          @target.send(method, *args)
        end
      end

      protected

      def dependent?
        @reflection.options[:dependent]
      end

      def with_scope(*args, &block)
        @reflection.klass.send :with_scope, *args, &block
      end

      private

      def method_missing(method, *args)
        if load_target
          unless @target.respond_to?(method)
            message = "undefined method '#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
            raise NoMethodError, message
          end

          if block_given?
            @target.send(method, *args) { |*block_args| yield(*block_args) }
          else
            @target.send(method, *args)
          end
        end
      end

      def load_target
        return nil unless defined?(@loaded)

        if !loaded? and (@owner.persisted? || foreign_key_present)
          @target = find_target
        end

        @loaded = true
        @target
      rescue NinjaModel::RecordNotFound
        reset
      end

      def foreign_key_present
        false
      end
    end
  end
end
