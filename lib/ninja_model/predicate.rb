module NinjaModel
  class Predicate

    PREDICATES = [:eq, :ne, :gt, :gte, :lt, :lte]

    attr_reader :attribute, :method, :value

    def initialize(attribute, method)
      @attribute = attribute
      @method = method
      @valued = false
    end

    def value=(value)
      @value = value
      @valued = true
    end

    def has_value?
      @valued
    end
  end
end
