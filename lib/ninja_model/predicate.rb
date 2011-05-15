module NinjaModel
  class Predicate

    PREDICATES = [:eq, :ne, :gt, :gte, :lt, :lte, :in]

    attr_reader :attribute, :meth, :value

    def initialize(attribute, meth, *args)
      @attribute = attribute
      @meth = meth
      @valued = !args.blank?
      @value = args.blank? ? nil : args.first
    end

    def value=(value)
      @value = value
      @valued = true
    end

    def has_value?
      @valued
    end

    def test(suspect)
      case meth
      when :eq
        suspect.eql?(value)
      when :ne
        !suspect.eql?(value)
      when :gt
        suspect > value
      when :gte
        suspect >= value
      when :lt
        suspect < value
      when :lte
        suspect <= value
      when :in
        value.include?(suspect)
      end
    end
  end
end
