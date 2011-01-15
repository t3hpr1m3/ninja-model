require 'active_support'
require 'active_model/attribute_methods'

module NinjaModel
  class Attribute
    attr_reader :name, :type, :default, :primary_key
    alias :primary_key? :primary_key
    alias :primary :primary_key

    def initialize(name, type, default, owner_class, options)
      @name, @type, @default = name.to_s, type, default
      @owner_class = owner_class
      @options = options
      @primary_key = options.key?(:primary_key) && options[:primary_key]
    end

    def define_methods!
      @owner_class.define_attribute_methods(true)
      @owner_class.primary_key = name.to_sym if @primary_key
    end

    def convert(value)
      case type
      when :string    then value
      when :text      then value
      when :integer   then value.to_i rescue value ? 1 : 0
      when :float     then value.to_f
      when :date      then ActiveRecord::ConnectionAdapters::Column.string_to_date(value)
      else value
      end
    end
  end

  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    module ClassMethods
      def attribute(name, data_type, *args)
        name = name.to_s
        opts = args.extract_options!
        default = args.first unless args.blank?
        new_attr = Attribute.new(name, data_type, default, self, opts)
        self.model_attributes << new_attr
        new_attr.define_methods!
      end

      def define_attribute_methods(force = false)
        return unless self.model_attributes
        undefine_attribute_methods if force
        super(self.model_attributes.map { |attr| attr.name })
      end

      def columns
        model_attributes
      end

      def model_attributes_hash
        @attributes_hash ||= HashWithIndifferentAccess[model_attributes.map { |attribute| [attribute.name, attribute] }]
      end

      alias :columns_hash :model_attributes_hash

      def attribute_names
        @attribute_names ||= model_attributes.map { |attribute| attribute.name }
      end

      alias :column_names :attribute_names
    end

    included do
      class_inheritable_accessor :model_attributes
      self.model_attributes = []
      attribute_method_suffix('', '=')
    end

    def attributes_from_model_attributes
      self.class.model_attributes.inject({}) do |result, attr|
        result[attr.name] = attr.default unless attr.name == self.class.primary_key
        result
      end
    end

    def write_attribute(name, value)
      name = name.to_s
      if a = self.class.model_attributes_hash[name]
        @attributes[name] = value
      else
        raise NoMethodError, "Unknown attribute #{name.inspect}"
      end
    end

    def read_attribute(name)
      name = name.to_s
      if !(value = @attributes[name]).nil?
        self.class.model_attributes_hash[name].convert(@attributes[name])
      else
        nil
      end
    end

    def [](attr_name)
      read_attribute(attr_name)
    end

    def []=(attr_name, value)
      write_attribute(attr_name, value)
    end

    def attributes=(new_attributes)
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys

      attributes.each do |k,v|
        respond_to?("#{k}=".to_sym) ? send("#{k}=".to_sym, v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end

    def attribute_method?(name)
      name = name.to_s
      self.class.model_attributes_hash.key?(name)
    end

    private

    def attribute(name)
      read_attribute(name)
    end

    def attribute=(name, value)
      write_attribute(name, value)
    end
  end
end
