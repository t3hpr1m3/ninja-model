module NinjaModel
  class Base
    include Attributes
    include Callbacks
    include Identity
    include Persistence
    include Scoping
    include Validation
    include Adapters
    extend ActiveModel::Naming

    class_inheritable_accessor :default_scoping, :instance_writer => false
    self.default_scoping = []

    class << self

      delegate :find, :first, :last, :all, :to => :scoped
      delegate :where, :order, :limit, :to => :scoped

      def configuration_path
        @config_path ||= File.join(Rails.root, "config/ninja_model.yml")
      end

      def configuration_path=(new_path)
        @config_path = new_path
      end

      def configuration
        require 'erb'
        require 'yaml'
        @configuration ||= YAML::load(ERB.new(IO.read(configuration_path)).result).with_indifferent_access
      end

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

    attr_reader :attributes

    def initialize(attributes={})
      @attributes = attributes_from_model_attributes.with_indifferent_access
      self.attributes = attributes unless attributes.nil?
      @persisted = false
      @readonly = true
      @destroyed = false
    end

    def instantiate(record)
      @attributes = record
      @readonly = @destroyed = false
      @persisted = true
      self
    end

  end
end

require 'ninja_model/core_ext/symbol'
