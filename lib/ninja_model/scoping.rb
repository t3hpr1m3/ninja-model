require 'active_support/core_ext/array'
require 'active_support/core_ext/kernel/singleton_class'

module NinjaModel
  module Scoping
    extend ActiveSupport::Concern

    module ClassMethods
      def scoped(options = nil)
        if options
          scoped.apply_finder_options(options)
        else
          current_scoped_methods ? relation.merge(current_scoped_methods) : relation.clone
        end
      end

      def scopes
        read_inheritable_attribute(:scopes) || write_inheritable_attribute(:scopes, {})
      end

      def scope(name, scope_options = {}, &block)
        name = name.to_sym
        valid_scope_name?(name)
        extension = Module.new(&block) if block_given?

        scopes[name] = lambda do |*args|
          options = scope_options.is_a?(Proc) ? scope_options.call(*args) : scope_options
          relation = if options.is_a?(Hash)
                       scoped.apply_finder_options(options)
                     elsif options
                       scoped.merge(options)
                     else
                       scoped
                     end

          extension ? relation.extending(extension) : relation
        end

        singleton_class.send(:redefine_method, name, &scopes[name])
      end

      def valid_scope_name?(name)
        if !scopes[name] && respond_to?(name, true)
          logger.warn "Creating scope :#{name}.  Overwriting existing method #{self.name}.#{name}."
        end
      end
    end
  end
end
