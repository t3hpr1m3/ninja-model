require 'ninja_model/relation/query_methods'
require 'ninja_model/relation/finder_methods'
require 'ninja_model/relation/spawn_methods'

module NinjaModel
  class Relation
    include QueryMethods, FinderMethods, SpawnMethods

    delegate :length, :each, :map, :collect, :all?, :include?, :to => :to_a

    attr_reader :klass, :loaded

    attr_accessor :ordering, :predicates, :limit_value, :offset_value, :readonly_value
    attr_accessor :default_scoped
    alias :default_scoped? :default_scoped

    alias :loaded? :loaded

    SINGLE_VALUE_ATTRS = [:limit, :offset, :readonly]
    MULTI_VALUE_ATTRS = [:ordering, :predicates]

    def initialize(klass)
      @klass  = klass
      @loaded = false
      @default_scoped = false

      SINGLE_VALUE_ATTRS.each do |v|
        instance_variable_set("@#{v}_value".to_sym, nil)
      end

      MULTI_VALUE_ATTRS.each do |v|
        instance_variable_set("@#{v}".to_sym, [])
      end
    end

    def new(*args, &block)
      scoping { @klass.new(*args, &block) }
    end

    alias build new

    def to_a
      @records ||= begin
        records = @klass.adapter.read(self)
        @loaded = true
        records
      end
    end
    alias :to_ary :to_a

    def scoping
      @klass.scoped_methods << self
      begin
        yield
      ensure
        @klass.scoped_methods.pop
      end
    end

    def size
      to_a.length
    end

    def blank?
      empty?
    end

    def empty?
      size.zero?
    end

    alias :inspect! :inspect
    def inspect
      to_a.inspect
    end

    def scope_for_create
      Hash[@predicates.find_all { |w|
        w.respond_to?(:meth) && w.meth == :eq
      }.map { |where|
        [
          where.attribute,
          where.value
        ]
      }]
    end

    protected

    def method_missing(method, *args, &block)
      if Array.method_defined?(method)
        to_a.send(method, *args, &block)
      elsif @klass.singleton_class.respond_to?(method)
        merge(@klass.singleton_class.send(method, *args, &block))
      elsif @klass.respond_to?(method)
        scoping { @klass.send(method, *args, &block) }
      else
        super
      end
    end
  end
end
