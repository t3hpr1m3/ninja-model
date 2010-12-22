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

    def test(suspect)
      case method
      when :eq
        suspect.eql?(value)
      when :ne
        suspect != value
      when :gt
        suspect > value
      when :gte
        suspect >= value
      when :lt
        suspect < value
      when :lte
        suspect <= value
      end
    end
  end
end
