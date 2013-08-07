require 'ninja_model/core_ext/symbol'
require 'active_record/named_scope'
require 'active_record/aggregations'

module NinjaModel
  class Base
    include Callbacks
    include AttributeMethods
    include Identity
    include Persistence
    include Validation
    include Adapters
    include Associations
    include Marshalling
    include Reflection
    extend ActiveModel::Translation
    extend ActiveModel::Naming
    include ActiveModel::Observing
    include ActiveRecord::Aggregations
    include ActiveRecord::NamedScope
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    define_model_callbacks :initialize, :find, :touch, :only => :after
    class_attribute :pluralize_table_names, :instance_writer => false
    self.pluralize_table_names = true

    class_attribute :default_scopes
    self.default_scopes = []

    class << self

      delegate :find, :first, :last, :all, :exists?, :to => :scoped
      delegate :where, :order, :limit, :to => :scoped

      def relation
        @relation ||= Relation.new(self)
      end

      def logger
        ::NinjaModel.logger
      end

      def unscoped
        block_given? ? relation.scoping { yield } : relation
      end

      def scoped_methods
        key = "#{self}_scoped_methods".to_sym
        Thread.current[key] = Thread.current[key].presence || self.default_scopes.dup
      end

      def default_scope(scope = {})
        scope = Proc.new if block_given?
        self.default_scopes = default_scopes + [scope]
      end

      def current_scope
        current_scoped_methods
      end

      def current_scoped_methods
        last = scoped_methods.last
        last.is_a?(Proc) ? unscoped(&last) : last
      end

      def reset_scoped_methods
        Thread.current["#{self}_scoped_methods".to_sym] = nil
      end


      def build_finder_relation(options = {}, scope = nil)
        relation = options.is_a?(Hash) ? unscoped.apply_finder_options(options) : options
        relation = scope.merge(relation) if scope
        relation
      end

      def compute_type(type_name)
        if type_name.match(/^::/)
          # If the type is prefixed with a scope operator then we assume that
          # the type_name is an absolute reference.
          ActiveSupport::Dependencies.constantize(type_name)
        else
          # Build a list of candidates to search for
          candidates = []
          name.scan(/::|$/) { candidates.unshift "#{$`}::#{type_name}" }
          candidates << type_name

          candidates.each do |candidate|
            begin
              constant = ActiveSupport::Dependencies.constantize(candidate)
              return constant if candidate == constant.to_s
            rescue NameError => e
              # We don't want to swallow NoMethodError < NameError errors
              raise e unless e.instance_of?(NameError)
            end
          end

          raise NameError, "uninitialized constant #{candidates.first}"
        end
      end
    end

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes

      attributes = new_attributes.stringify_keys

      attributes.each do |k, v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        else
          raise(StandardError, "unknown attribute: #{k}")
        end
      end
    end

    def attributes
      self.class.attribute_names.inject({}) { |h, v|
        h[v] = read_attribute(v); h
      }
    end

    def initialize(attributes = nil, options = {})
      @attributes = attributes_from_model_attributes
      @association_cache = {}
      @aggregation_cache = {}
      @persisted = false
      @readonly = true
      @destroyed = false

      populate_with_current_scope_attributes

      self.attributes = attributes unless attributes.nil?

      yield self if block_given?
      run_callbacks :initialize
    end

    def instantiate(record)
      @attributes = record.stringify_keys
      @readonly = @destroyed = false
      @persisted = true

      _run_find_callbacks
      _run_initialize_callbacks
      self
    end

    def derive_class(association_id)
      klass = association_id.to_s.camelize
      klass = klass.singularize
      compute_type(klass)
    end

    def attribute_for_inspect(attr_name)
      value = read_attribute(attr_name)
      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end

    def inspect
      attributes_as_nice_string = self.class.attribute_names.collect { |attr|
        "#{attr}: #{attribute_for_inspect(attr)}"
      }.compact.join(', ')
      "#<#{self.class} #{attributes_as_nice_string}>"
    end


    private

    def populate_with_current_scope_attributes
      return unless self.class.scope_attributes?

      self.class.scope_attributes.each do |att, value|
        send("#{att}=", value) if respond_to?("#{att}=")
      end
    end
  end
end

ActiveSupport.run_load_hooks(:ninja_model, NinjaModel::Base)
