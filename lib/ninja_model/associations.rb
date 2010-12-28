require 'active_support/concern'
require 'ninja_model/associations/active_record_proxy'

module NinjaModel
  module Associations
    extend ActiveSupport::Concern

    autoload :HasManyAssociation, 'ninja_model/associations/has_many_association'


    module ClassMethods
      def has_one(association_id, options = {})
        if ninja_model?(association_id)
          reflection = create_has_one_reflection(association_id, options)
          #association_accessor_methods(reflection, HasOneAssociation)
          #association_accessor_methods(reflection, HasOneAssociation)
          #association_constructor_method(:build, reflection, HasOneAssociation)
          #association_constructor_method(:create, reflection, HasOneAssociation)
          #configure_dependency_for_has_one(reflection)
        else
          #puts "Setting up has_one proxy for #{association_id}"
          proxy.handle_association(:has_one, association_id, options)
        end
      end

      def belongs_to(association_id, options = {})
        if ninja_model?(association_id)
          reflection = create_belongs_to_reflection(association_id, options)
        else
          proxy.handle_association(:belongs_to, association_id, options)
        end
      end

      def has_many(association_id, options = {})
        if ninja_model?(association_id)
          reflection = create_has_many_reflection(association_id, options)
          collection_accessor_methods(reflection, HasManyAssociation)
          #collection_accessor_methods(reflection, HasManyAssociation)
        else
          proxy.handle_association(:has_many, association_id, options)
        end
      end

      def proxy
        read_inheritable_attribute(:proxy) || write_inheritable_attribute(:proxy, ActiveRecordProxy.new(self))
      end

      private

      def create_has_many_reflection(association, options = {})
        create_reflection(:has_many, association, options, self)
        #options[:extend] = create_extension_modules(association, extension
      end

      def create_belongs_to_reflection(association, options = {})
        create_reflection(:belongs_to, association, options, self)
      end

      def association_accessor_methods(reflection, association_proxy_class)
        redefine_method(reflection.name) do |*params|
          association = association_instance_get(reflection.name)

          if association.nil?
            association = association_proxy_class.new(self, reflection)
          end
          association_instance_set(reflection.name, association)
          association
        end
      end

      def collection_accessor_methods(reflection, association_proxy_class)
        collection_reader_method(reflection, association_proxy_class)
      end

      def collection_reader_method(reflection, association_proxy_class)
        redefine_method(reflection.name) do |*params|
          association = association_instance_get(reflection.name)

          if association.nil?
            association = association_proxy_class.new(self, reflection)
          end
          association_instance_set(reflection.name, association)
          association
        end
      end

      def association_instance_get(name)
        ivar = "@#{name}"
        if instance_variable_defined?(ivar)
          association = instance_variable_get(ivar)
          association if association.respond_to?(:loaded?)
        end
      end
    end

    def method_missing(method, *args)
      if self.class.read_inheritable_attribute(:proxy) && proxy.respond_to?(method)
        proxy.send(method, *args)
      end
    end
  end
end
