module NinjaModel
  module Associations
    extend ActiveSupport::Concern

    autoload :Association, 'ninja_model/associations/association'
    autoload :AssociationProxy, 'ninja_model/associations/association_proxy'
    autoload :AssociationScope, 'ninja_model/associations/association_scope'
    autoload :BelongsToAssociation, 'ninja_model/associations/belongs_to_association'
    autoload :CollectionAssociation, 'ninja_model/associations/collection_association'
    autoload :CollectionProxy, 'ninja_model/associations/collection_proxy'
    autoload :HasOneAssociation, 'ninja_model/associations/has_one_association'
    autoload :HasManyAssociation, 'ninja_model/associations/has_many_association'
    autoload :SingularAssociation, 'ninja_model/associations/singular_association'

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

    module ClassMethods
      def has_one(association_id, options = {})
        reflection = create_has_one_reflection(association_id, options)
        association_accessor_methods(reflection, Associations::HasOneAssociation)
        # TODO: Implement the build/create association methods
        #association_constructor_method(:build, reflection, HasOneAssociation)
        #association_constructor_method(:create, reflection, HasOneAssociation)
        #configure_dependency_for_has_one(reflection)
      end

      def belongs_to(association_id, options = {})
        reflection = create_belongs_to_reflection(association_id, options)
        association_accessor_methods(reflection, Associations::BelongsToAssociation)
        # TODO: Implement the build/create association methods
        #association_constructor_method(:build, reflection, BelongsToAssociation)
        #association_constructor_method(:create, reflection, BelongsToAssociation)
      end

      def has_many(association_id, options = {})
        reflection = create_has_many_reflection(association_id, options)
        collection_accessor_methods(reflection, Associations::HasManyAssociation)
      end

      private

      def create_has_one_reflection(association, options = {})
        create_reflection(:has_one, association, options, self)
      end

      def create_has_many_reflection(association, options = {})
        create_reflection(:has_many, association, options, self)
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
            if retval.nil? and association_proxy_class == Associations::BelongsToAssociation
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
          return if target.nil? and association_proxy_class == Associations::BelongsToAssociation
          association = association_proxy_class.new(self, reflection)
          association.target = target
          association_instance_set(reflection.name, association)
        end
      end

      def collection_accessor_methods(reflection, association_proxy_class, writer = true)
        collection_reader_method(reflection, association_proxy_class)

        if writer
          redefine_method("#{reflection.name}=") do |new_value|
            association = send(reflection.name)
            association.replace(new_value)
            association
          end
        end
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
  end
end
