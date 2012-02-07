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

    module Builder
      autoload :Association, 'ninja_model/associations/builder/association'
      autoload :SingularAssociation, 'ninja_model/associations/builder/singular_association'
      autoload :CollectionAssociation, 'ninja_model/associations/builder/collection_association'
      autoload :HasMany, 'ninja_model/associations/builder/has_many'
      autoload :BelongsTo, 'ninja_model/associations/builder/belongs_to'
      autoload :HasOne, 'ninja_model/associations/builder/has_one'
    end

    attr_reader :association_cache

    def association(name)
      association = association_instance_get(name)

      if association.nil?
        reflection = self.class.reflect_on_association(name)
        association = reflection.association_class.new(self, reflection)
        association_instance_set(name, association)
      end
      association
    end

    private

    def association_instance_get(name)
      @association_cache[name.to_sym]
    end

    def association_instance_set(name, association)
      @association_cache[name.to_sym] = association
    end

    module ClassMethods
      def add_autosave_association_callbacks(reflection)
      end
      def has_one(name, options = {})
        klass = compute_klass(name, :has_one, options)
        if NinjaModel.ninja_model?(klass)
          Builder::HasOne.build(self, name, options)
        else
          ActiveRecord::Associations::Builder::HasOne.build(self, name, options)
        end
      end

      def belongs_to(name, options = {}, &extension)
        klass = compute_klass(name, :belongs_to, options)
        if NinjaModel.ninja_model?(klass)
          Builder::BelongsTo.build(self, name, options)
        else
          ActiveRecord::Associations::Builder::BelongsTo.build(self, name, options)
        end
      end

      def has_many(name, options = {}, &extension)
        klass = compute_klass(name, :has_many, options)
        if NinjaModel.ninja_model?(klass)
          Builder::HasMany.build(self, name, options)
        else
          ActiveRecord::Associations::Builder::HasMany.build(self, name, options)
        end
      end

      private

      def compute_klass(name, macro, options)
        klass = options[:class_name] || name
        klass = klass.to_s.camelize
        klass = klass.singularize if macro.eql?(:has_many)
        klass = compute_type(klass)
      end
    end
  end
end
