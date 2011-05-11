module CustomMatchers
  class ConvertMatcher
    def initialize(value)
      puts "asdfaj;lskdfj;lkasjdf;a"
      @value_to_convert = value
    end

    def matches?(actual)
      puts "**********************"
      result = actual.convert(@value_to_convert)
      unless defined?(@expected_value)
        false
      end
      #result.eql?(@expected_value)
      false
    end

    def to(expected)
      @expected_value = expected
    end

    def description
      "convert #{@value_to_convert} to #{@expected_value}"
    end
  end

  def convert(value)
    ConvertMatcher.new(value)
  end
end
