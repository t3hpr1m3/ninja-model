module NinjaModel
  class Base
    class << self
      def create_reflection(macro, name, options, ninja_model)
        case macro
        when :has_many, :belongs_to, :has_one
          reflection = Reflection::AssociationReflection.new(macro, name, options, ninja_model)
        end
        write_inheritable_hash :reflections, name => reflection
        reflection
      end

      def reflections
        read_inheritable_attribute(:reflections) || write_inheritable_attribute(:reflections, {})
      end

      def reflect_on_association(association)
        reflections[association].is_a?(Reflection::AssociationReflection) ? reflections[association] : nil
      end
    end
  end

  module Reflection

    class MacroReflection
      def initialize(macro, name, options, ninja_model)
        @macro, @name, @options, @ninja_model = macro, name, options, ninja_model
      end

      attr_reader :ninja_model, :name, :macro, :options

      def klass
        @klass ||= class_name.camelize.constantize
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
        @primary_key_name
      end

      def association_foreign_key
        @association_foreign_key ||= @options[:association_foreign_key] || class_name.foreign_key
      end

      def collection?
        @collection
      end

      def validate?
        !options[:validate].nil? ? options[:validate] : (options[:autosave] == true || macro == :has_many)
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
          ninja_model.name.demodulize.foreign_key
        end
      end
    end
  end
end
