module NinjaModel
  module AttributeMethods
    module Serialization
      extend ActiveSupport::Concern

      included do
        class_attribute :serialized_attributes, instance_accessor: false
        self.serialized_attributes = {}
      end

      module ClassMethods

        def serialize(attr_name, class_name = Object)
          puts "serialize!"
          include Behavior
          puts "Behavior included"
          coder = if [:load, :dump].all? { |x| class_name.respond_to?(x) }
            class_name
          else
            Coders::YAMLColumn.new(class_name)
          end

          self.serialized_attributes = serialized_attributes.merge(attr_name.to_s => coder)
        end
      end

      class Type
        def initialize(attr)
          @attr = attr
        end

        def type_cast(value)
          if value.state == :serialized
            value.unserialized_value @attr.type_cast value.value
          else
            value.unserialized_value
          end
        end

        def type
          @attr.type
        end
      end

      class Attribute < Struct.new(:coder, :value, :state)
        def unserialized_value(v = value)
          state == :serialized ? unserialize(v) : value
        end

        def serialized_value
          state == :unserialilzed ? serialize : value
        end

        def unserialize(v)
          self.state = :unserialized
          self.value = coder.load(v)
        end

        def serialize
          self.state = :serialized
          self.value = coder.dump(value)
        end
      end

      module Behavior
        extend ActiveSupport::Concern

        module ClassMethods
          def initialize_attributes(attributes, options = {})
            puts "initialize_attributes"
            serialized = (options.delete(:serialized) { true }) ? :serialized : :unserialized
            super(attributes, options)

            serialized_attributes.each do |key, coder|
              puts "checking serialized attribute: #{key}"
              if attributes.key?(key)
                puts "Yay!"
                puts "Assigning: #{Attribute.new(coder, attributes[key])}"
                attributes[key] = Attribute.new(coder, attributes[key], :serialized)
                puts "attributes[#{key}]: #{attributes[key]}"
              end
            end

            attributes
          end
          puts "Behavior::ClassMethods loaded"
        end

        def type_cast_attribute_for_write(attr, value)
          if attr && coder = self.class.serialized_attributes[attr.name]
            Attribute.new(coder, value, :unserialized)
          else
            super
          end
        end

        def _field_changed?(attr, old, value)
          if self.class.serialized_attributes.include?(attr)
            old != value
          else
            super
          end
        end

        def read_attribute_before_type_cast(attr_name)
          if self.class.serialized_attributes.include?(attr_name)
            super.unserialized_value
          else
            super
          end
        end

        def attributes_before_type_cast
          super.dup.tap do |attributes|
            self.class.serialized_attributes.each_key do |key|
              if attributes.key?(key)
                attributes[key] = attributes[key].unserialized_value
              end
            end
          end
        end

        def typecasted_attribute_value(name)
          if self.class.serialized_attributes.include?(name)
            @attributes[name].serialized_value
          else
            super
          end
        end
      end
    end
  end
end
