require 'active_support/concern'
require 'ninja_model/associations/active_record_proxy'
require 'ninja_model/associations/ninja_model_proxy'

module ActiveRecord
  module Associations
    module ClassMethods
      alias :has_one_without_ninja_model :has_one
      def has_one(association_id, options = {})
        if ninja_model?(:has_one, options[:class_name] || association_id)
          ninja_proxy.handle_association(:has_one, association_id, options)
        else
          has_one_without_ninja_model(association_id, options)
        end
      end

      def ninja_proxy
        read_inheritable_attribute(:ninja_proxy) || write_inheritable_attribute(:ninja_proxy, NinjaModel::Associations::NinjaModelProxy.new(self))
      end

      private

      def ninja_model?(macro, association)
        klass = association.to_s.camelize
        klass = klass.singularize unless [:has_one, :belongs_to].include?(macro)
        klass = klass.constantize
        klass.ancestors.include?(NinjaModel::Base)
      end
    end

    def method_missing(method, *args)
      begin
        super
      rescue NoMethodError => ex
        if self.class.read_inheritable_attribute(:ninja_proxy) && ninja_proxy.respond_to?(method)
          ninja_proxy.send(method, *args)
        else
          raise ex
        end
      end
    end
  end

  module Reflection
    module ClassMethods
      alias :reflect_on_association_without_ninja_model :reflect_on_association
      def reflect_on_association(association)
        if read_inheritable_attribute(:ninja_proxy) && ninja_proxy.proxy_klass.reflections.include?(association)
          ninja_proxy.proxy_klass.reflect_on_association(association)
        else
          reflect_on_association_without_ninja_model(association)
        end
      end
    end
  end
end

module NinjaModel
  module Associations
    extend ActiveSupport::Concern

    autoload :AssociationProxy, 'ninja_model/associations/association_proxy'
    autoload :HasOneAssociation, 'ninja_model/associations/has_one_association'
    autoload :HasManyAssociation, 'ninja_model/associations/has_many_association'
    autoload :BelongsToAssociation, 'ninja_model/associations/belongs_to_association'


    module ClassMethods
      def has_one(association_id, options = {})
        if ninja_model?(:has_one, options[:class_name] || association_id)
          reflection = create_has_one_reflection(association_id, options)
          association_accessor_methods(reflection, HasOneAssociation)
          #association_constructor_method(:build, reflection, HasOneAssociation)
          #association_constructor_method(:create, reflection, HasOneAssociation)
          #configure_dependency_for_has_one(reflection)
        else
          #puts "Setting up has_one proxy for #{association_id}"
          proxy.handle_association(:has_one, association_id, options)
        end
      end

      def belongs_to(association_id, options = {})
        if ninja_model?(:belongs_to, options[:class_name] || association_id)
          reflection = create_belongs_to_reflection(association_id, options)
          association_accessor_methods(reflection, BelongsToAssociation)
          #association_constructor_method(:build, reflection, BelongsToAssociation)
          #association_constructor_method(:create, reflection, BelongsToAssociation)
        else
          proxy.handle_association(:belongs_to, association_id, options)
        end
      end

      def has_many(association_id, options = {})
        if ninja_model?(:has_many, association_id)
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

      def create_has_one_reflection(association, options = {})
        create_reflection(:has_one, association, options, self)
      end

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
            retval = association.reload
            if retval.nil? and association_proxy_class == BelongsToAssociation
              association_instance_set(reflection.name, nil)
              return nil
            end
            association_instance_set(reflection.name, association)
          end
          association.target.nil? ? nil : association
        end

        redefine_method("loaded_#{reflection.name}?") do
          association = association_instance_get(reflection.name)
          association && association.loaded?
        end

        redefine_method("#{reflection.name}=") do |new_value|
          association = association_instance_get(reflection.name)
          if association.nil? || association.target != new_value
            association = association_proxy_class.new(self, reflection)
          end

          association.replace(new_value)
          association_instance_set(reflection.name, new_value.nil? ? nil : association)
        end

        redefine_method("set_#{reflection.name}_target") do |target|
          return if target.nil? and association_proxy_class == BelongsToAssociation
          association = association_proxy_class.new(self, reflection)
          association.target = target
          association_instance_set(reflection.name, association)
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
    end

    def association_instance_get(name)
      ivar = "@#{name}"
      if instance_variable_defined?(ivar)
        association = instance_variable_get(ivar)
        association if association.respond_to?(:loaded?)
      end
    end

    def association_instance_set(name, association)
      instance_variable_set("@#{name}", association)
    end

    def method_missing(method, *args)
      if self.class.read_inheritable_attribute(:proxy) && proxy.respond_to?(method)
        proxy.send(method, *args)
      else
        super
      end
    end
  end
end
