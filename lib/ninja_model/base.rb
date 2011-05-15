require 'ninja_model/attribute_methods'
require 'ninja_model/associations'
require 'ninja_model/adapters'
require 'ninja_model/callbacks'
require 'ninja_model/identity'
require 'ninja_model/persistence'
require 'ninja_model/predicate'
require 'ninja_model/reflection'
require 'ninja_model/relation'
require 'ninja_model/validation'
require 'ninja_model/attribute'
require 'active_record/named_scope'
require 'active_record/aggregations'

module NinjaModel
  class Base
    include AttributeMethods
    include Identity
    include Persistence
    include Validation
    include Adapters
    include Associations
    include Reflection
    extend ActiveModel::Translation
    extend ActiveModel::Naming
    include ActiveModel::Observing
    include ActiveModel::Dirty
    include ActiveRecord::Aggregations
    include ActiveRecord::NamedScope

    define_model_callbacks :initialize, :find, :touch, :only => :after

    class_inheritable_accessor :default_scoping, :instance_writer => false
    self.default_scoping = []

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
        Thread.current[key] = Thread.current[key].presence || self.default_scoping.dup
      end

      def default_scope(options = {})
        reset_scoped_methods
        self.default_scoping << build_finder_relation(options, default_scoping.pop)
      end

      def current_scoped_methods
        last = scoped_methods.last
        last.is_a?(Proc) ? unscoped(&last) : last
      end

      def reset_scoped_methods
        Thread.current["#{self}_scoped_methods".to_sym] = nil
      end

      private

      def build_finder_relation(options = {}, scope = nil)
        relation = options.is_a?(Hash) ? unscoped.apply_finder_options(options) : options
        relation = scope.merge(relation) if scope
        relation
      end
    end

    def attributes
      attrs = {}
      self.class.attribute_names.each { |name|
        attrs[name] = read_attribute(name)
      }
      attrs
    end

    def initialize(attributes = nil)
      @attributes = attributes_from_model_attributes
      self.attributes = attributes unless attributes.nil?
      @persisted = false
      @readonly = true
      @destroyed = false
      result = yield self if block_given?
      _run_initialize_callbacks
      result
    end

    def instantiate(record)
      @attributes = record.stringify_keys
      @readonly = @destroyed = false
      @persisted = true
      _run_find_callbacks
      _run_initialize_callbacks
      self
    end
  end
end
