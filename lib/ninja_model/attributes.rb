require 'active_support'
require 'active_model/attribute_methods'

module NinjaModel
  class Attribute
    attr_reader :name, :type, :default, :primary_key
    alias :primary_key? :primary_key

    def initialize(name, type, owner_class, options)
      @name = name.to_s
      @type = type
      @owner_class = owner_class
      @options = options
      @default = options[:default] if options.key?(:default)
      @primary_key = options.key?(:primary_key) && options[:primary_key]
    end

    def define_methods!
      @owner_class.define_attribute_methods(true)
      @owner_class.primary_key = name.to_sym if @primary_key
    end

    def convert(value)
      case @type
      when :string
        value.to_s
      when :integer
        value.to_i
      when :float
        value.to_f
      end
    end

  end

  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    module ClassMethods
      def attribute(name, data_type, options = {})
        new_attr = Attribute.new(name, data_type, self, options)
        write_inheritable_hash(:model_attributes, {name => new_attr}.with_indifferent_access)
        new_attr.define_methods!
      end

      def define_attribute_methods(force = false)
        return unless model_attributes
        undefine_attribute_methods if force
        super(model_attributes.keys)
      end
    end

    included do
      class_inheritable_hash :model_attributes
      write_inheritable_attribute :model_attributes, {}.with_indifferent_access
      attribute_method_suffix('', '=')
    end

    def attributes_from_model_attributes
      self.class.model_attributes.inject({}.with_indifferent_access) do |attributes, (name, attribute)|
        attributes[name] = attribute.default unless attribute.name == self.class.primary_key
        attributes
      end
    end

    def attributes_for_active_record
      self.attributes.to_a.inject({}) do |result, attr|
        result[attr.first.to_s] = attr.last
        result
      end
    end

    def write_attribute(name, value)
      if a = self.class.model_attributes.with_indifferent_access[name]
        @attributes[name.to_s] = value
      else
        raise NoMethodError, "Unknown attribute #{name.inspect}"
      end
    end

    def read_attribute(name)
      @attributes[name.to_sym]
    end

    protected

    def attribute_method?(name)
      model_attributes.with_indifferent_access.key?(name)
    end

    private

    def attributes=(new_attributes)
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys

      attributes.each do |k,v|
        respond_to?("#{k}=".to_sym) ? send("#{k}=".to_sym, v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end

    def attribute(name)
      read_attribute(name.to_sym)
    end

    def attribute=(name, value)
      write_attribute(name.to_sym, value)
    end
  end
end
