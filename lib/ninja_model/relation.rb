module NinjaModel
  class Relation
    include QueryMethods, FinderMethods, SpawnMethods

    delegate :each, :all?, :include?, :to => :to_a

    attr_reader :klass, :loaded

    attr_accessor :ordering, :predicates, :limit_value, :offset_value

    alias :loaded? :loaded

    SINGLE_VALUE_ATTRS = [:limit, :offset]
    MULTI_VALUE_ATTRS = [:ordering, :predicates]

    def initialize(klass)
      @klass  = klass
      @loaded = false

      SINGLE_VALUE_ATTRS.each do |v|
        instance_variable_set("@#{v}_value".to_sym, nil)
      end

      MULTI_VALUE_ATTRS.each do |v|
        instance_variable_set("@#{v}".to_sym, [])
      end
    end

    def to_a
      @klass.adapter.read(self)
    end
  end
end
