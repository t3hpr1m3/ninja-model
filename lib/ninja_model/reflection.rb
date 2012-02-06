module NinjaModel
  module Reflection
    extend ActiveSupport::Concern

    included do
      class_attribute :reflections
      self.reflections = {}
    end

    module ClassMethods
      def create_reflection(macro, name, options, ninja_model)
        case macro
        when :has_many, :belongs_to, :has_one
          reflection = Reflection::AssociationReflection.new(macro, name, options, ninja_model)
        end
        self.reflections = self.reflections.merge(name => reflection)
        reflection
      end

      def reflections
        read_inheritable_attribute(:reflections) || write_inheritable_attribute(:reflections, {})
      end

      def reflect_on_association(association)
        reflections[association].is_a?(Reflection::AssociationReflection) ? reflections[association] : nil
      end
    end

    class MacroReflection
      def initialize(macro, name, options, ninja_model)
        @macro, @name, @options, @ninja_model = macro, name, options, ninja_model
      end

      attr_reader :ninja_model, :name, :macro, :options
      alias :source_macro :macro

      def klass
        @klass ||= ninja_model.send(:compute_type, class_name)
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
      attr_accessor :original_build_association_called # :nodoc
      def initialize(macro, name, options, ninja_model)
        super
        @collection = [:has_many].include?(macro)
      end

      def build_association(*options, &block)
        klass.new(*options, &block)
      end

      def create_association(*options)
        klass.create(*options)
      end

      def create_association!(*options)
        klass.create!(*options)
      end

      def foreign_key
        @foreign_key ||= options[:foreign_key] || derive_foreign_key
      end

      def primary_key_name
        foreign_key
      end

      def primary_key(klass)
        klass.primary_key || raise(StandardError, "#{klass} has no primary key defined")
      end

      def association_foreign_key
        @association_foreign_key ||= @options[:association_foreign_key] || class_name.foreign_key
      end

      def ninja_model_primary_key
        @ninja_model_primary_key ||= options[:primary_key] || primary_key(ninja_model)
      end
      alias :active_record_primary_key :ninja_model_primary_key

      def conditions
        [[options[:conditions]].compact]
      end

      def chain
        [self]
      end

      def collection?
        @collection
      end

      def validate?
        !options[:validate].nil? ? options[:validate] : (options[:autosave] == true || macro == :has_many)
      end

      def association_class
        case macro
        when :belongs_to
          Associations::BelongsToAssociation
        when :has_many
          Associations::HasManyAssociation
        when :has_one
          Associations::HasOneAssociation
        end
      end

      def chain
        [self]
      end

      def is_a?(c)
        if c.eql?(ActiveRecord::Reflection::AssociationReflection)
          true
        else
          super
        end
      end

      def check_validity!
        unless options[:polymorphic]
          if has_inverse? && inverse_of.nil?
            raise InverseOfAssociationNotFoundError.new(self)
          end
        end
      end

      def has_inverse?
        @options[:inverse_of]
      end

      def inverse_of
        if has_inverse?
          @inverse_of ||= klass.reflect_on_association(options[:inverse_of])
        end
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

      def derive_foreign_key
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
