module NinjaModel
  module Reflection
    extend ActiveSupport::Concern

    module ClassMethods
      def create_reflection(macro, name, options, ninja_model)
        case macro
        when :has_many, :belongs_to, :has_one
          reflection = AssociationReflection.new(macro, name, options, ninja_model)
        when :composed_of
        end
        write_inheritable_hash :reflections, name => reflection
        reflection
      end

      def ninja_model?(association)
        klass = association.to_s.camelize.singularize.constantize
        defined?(klass) && klass.ancestors.include?(NinjaModel::Base)
      end

      def reflections
        read_inheritable_attribute(:reflections) || write_inheritable_attribute(:reflections, {})
      end
    end

    class MacroReflection
      def initialize(macro, name, options, ninja_model)
        @macro, @name, @options, @ninja_model = macro, name, options, ninja_model
      end

      attr_reader :ninja_model, :name, :macro, :options

      def klass
        @klass ||= class_name.constantize
      end

      def class_name
        @class_name ||= options[:class_name] || derive_class_name
      end

      private

      def derive_class_name
        name.to_s.camelize
      end
    end

    class AssociationReflection < MacroReflection
      def initialize(macro, name, options, ninja_model)
        super
        @collection = [:has_many].include?(macro)
      end

      def build_association(*options)
        klass.new(*options)
      end

      def create_association(*options)
        klass.create(*options)
      end

      def create_association!(*options)
        klass.create!(*options)
      end

      def primary_key_name
        @primary_key_name ||= options[:foreign_key] || derive_primary_key_name
      end

      def collection?
        @collection
      end

      private

      def belongs_to?
        macro == :belongs_to
      end

      def derive_class_name
        class_name = name.to_s.camelize
        class_name = class_name.singularize if collection?
        class_name
      end

      def derive_primary_key_name
        if belongs_to?
          "#{name}_id"
        elsif options[:as]
          "#{options[:as]}_id"
        else
          ninja_model.name.foreign_key
        end
      end
    end
  end
end