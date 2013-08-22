module NinjaModel

  class UnknownAttributeError < NinjaModelError; end
  class AttributeAssignmentError < NinjaModelError
    attr_reader :exception, :attribute
    attr_reader :mymessage
    def initialize(message, exception, attribute)
      @exception = exception
      @attribute = attribute
      @message = message
      @mymessage = message
    end
  end
  class MultiparameterAssignmentErrors < NinjaModelError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end

  module AttributeMethods
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    include ActiveModel::AttributeMethods

    autoload :Serialization

    included do
      include ActiveModel::Dirty
      include Serialization
      class_attribute :model_attributes
      self.model_attributes = []
      attribute_method_suffix('', '=', '_before_type_cast')
    end

    module ClassMethods
      def attribute(name, data_type, *args)
        name = name.to_s
        opts = args.extract_options!
        primary = opts.delete(:primary_key)
        self.primary_key = name if primary.eql?(true)
        default = args.first unless args.blank?
        new_attr = Attribute.new(name, data_type, opts)
        self.model_attributes = model_attributes + [new_attr]
        define_attribute_method name
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
      @attributes_cache[name] || @attributes_cache.fetch(name) {
        attr = @attrs_hash.fetch(name) {
          return @attributes.fetch(name) {
            if name == 'id' && self.class.primary_key != name
              read_attribute(self.class.primary_key)
            end
          }
        }
      }

      value = @attributes.fetch(name) {
        return block_given? ? yield(name) : nil
      }

      if self.class.cache_attribute?(name)
        @attributes_cache[name] = column.type_cast(value)
      else
        column.type_cast value
      end
      #if !(value = @attributes[name]).nil?
      #  attr = @a
      #  self.class.model_attributes_hash[name].type_cast(@attributes[name])
      #else
      #  nil
      #end
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

      multi_parameter_attributes = []

      attributes.each do |k,v|
        if k.include?('(')
          multi_parameter_attributes << [k, v]
        else
          respond_to?("#{k}=".to_sym) ? send("#{k}=".to_sym, v) : raise(NinjaModel::UnknownAttributeError, "unknown attribute: #{k}")
        end
      end

      assign_multiparameter_attributes(multi_parameter_attributes)
    end

    #def attribute_method?(name)
    #  name = name.to_s
    #  self.class.model_attributes_hash.key?(name)
    #end

    private

    def assign_multiparameter_attributes(pairs)
      execute_callstack_for_multiparameter_attributes(
        extract_callstack_for_multiparameter_attributes(pairs)
      )
    end

    def instantiate_time_object(name, values)
      Time.time_with_datetime_fallback(@@default_timezone, *values)
    end

    def execute_callstack_for_multiparameter_attributes(callstack)
      errors = []
      callstack.each do |name, values_with_empty_parameters|
        begin
          klass = self.class.model_attributes_hash[name.to_s].klass
          # in order to allow a date to be set without a year, we must keep the empty values.
          # Otherwise, we wouldn't be able to distinguish it from a date with an empty day.
          values = values_with_empty_parameters.reject { |v| v.nil? }

          if values.empty?
            send(name + "=", nil)
          else

            value = if Date == klass
              begin
                values = values_with_empty_parameters.collect do |v| v.nil? ? 1 : v end
                Date.new(*values)
              rescue ArgumentError => ex # if Date.new raises an exception on an invalid date
                instantiate_time_object(name, values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
              end
            else
              klass.new(*values)
            end

            send(name + "=", value)
          end
        rescue => ex
          errors << AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
        end
      end
      unless errors.empty?
        raise MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end

    def extract_callstack_for_multiparameter_attributes(pairs)
      attributes = { }

      for pair in pairs
        multiparameter_name, value = pair
        attribute_name = multiparameter_name.split("(").first
        attributes[attribute_name] = [] unless attributes.include?(attribute_name)

        parameter_value = value.empty? ? nil : type_cast_attribute_value(multiparameter_name, value)
        attributes[attribute_name] << [ find_parameter_position(multiparameter_name), parameter_value ]
      end

      attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
    end

    def type_cast_attribute_value(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
    end

    def find_parameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
    end


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
