module NinjaModel
  class Base
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    class_inheritable_accessor :model_attributes
    self.model_attributes = []
    attribute_method_suffix('', '=', '_before_type_cast')

    class << self

      def attribute(name, data_type, *args)
        name = name.to_s
        opts = args.extract_options!
        primary = opts.delete(:primary_key)
        self.primary_key = name if primary.eql?(true)
        default = args.first unless args.blank?
        new_attr = Attribute.new(name, data_type, opts)
        self.model_attributes << new_attr
        define_attribute_methods(true)
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
  end

  module AttributeMethods

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
      unless read_attribute(name).eql?(value)
        attribute_will_change!(name)
        write_attribute(name, value)
      end
    end

    def attribute_before_type_cast(name)
      @attributes[name]
    end
  end
end
