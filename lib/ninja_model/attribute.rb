require 'active_support/core_ext/date_time/conversions'

module NinjaModel
  class UnsupportedType < NinjaModelError; end
  class InvalidConversion < NinjaModelError; end

  class Attribute
    attr_reader :name, :type, :default

    VALID_TYPES = [:string, :integer, :float, :date, :datetime, :boolean]

    def initialize(name, type, options = {})
      @name, @type = name.to_s, type
      @default = options[:default]
      raise UnsupportedType.new("Invalid type: #{@type}") unless VALID_TYPES.include?(@type)
    end

    def number?
      [:integer, :float].include?(@type)
    end

    #
    # Most of the following code was taken from ActiveRecord.  Credit to the
    # Rails team is due.
    #
    def klass
      case type
        when :integer       then Fixnum
        when :float         then Float
        when :decimal       then BigDecimal
        when :datetime      then Time
        when :date          then Date
        when :timestamp     then Time
        when :time          then Time
        when :text, :string then String
        when :binary        then String
        when :boolean       then Object
      end
    end

    def convert(value)
      case type
      when :string    then self.class.convert_to_string(value)
      when :integer   then value.to_i rescue value ? 1 : 0
      when :float     then value.to_f rescue value ? 1.0 : 0.0
      when :date      then self.class.string_to_date(value)
      when :datetime  then self.class.string_to_time(value)
      when :boolean   then self.class.value_to_boolean(value)
      end
    end

    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set
    FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE'].to_set

    module Format
      ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/
      ISO_DATETIME = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?\z/
    end

    class << self

      def convert_to_string(value)
        case value
        when String, NilClass
          value
        when Fixnum, Float, Date, DateTime, TrueClass, FalseClass
          value.to_s
        else
          raise InvalidConversion.new("Unable to convert #{value.inspect} to string")
        end
      end

      def string_to_date(string)
        return string unless string.is_a?(String)
        return nil if string.empty?

        fast_string_to_date(string) || fallback_string_to_date(string)
      end

      def string_to_time(string)
        return string unless string.is_a?(String)
        return nil if string.empty?

        fast_string_to_time(string) || fallback_string_to_time(string)
      end

      # convert something to a boolean
      def value_to_boolean(value)
        if value.is_a?(String) && value.blank?
          nil
        else
          TRUE_VALUES.include?(value)
        end
      end

      protected

      # '0.123456' -> 123456
      # '1.123456' -> 123456
      def microseconds(time)
        ((time[:sec_fraction].to_f % 1) * 1_000_000).to_i
      end

      def new_date(year, mon, mday)
        if year && year != 0
          Date.new(year, mon, mday) rescue nil
        end
      end

      def new_time(year, mon, mday, hour, min, sec, microsec)
        # Treat 0000-00-00 00:00:00 as nil.
        return nil if year.nil? || year == 0

        DateTime.new(year, mon, mday, hour, min, sec, microsec) rescue nil
      end

      def fast_string_to_date(string)
        if string =~ Format::ISO_DATE
          new_date $1.to_i, $2.to_i, $3.to_i
        end
      end

      # Doesn't handle time zones.
      def fast_string_to_time(string)
        if string =~ Format::ISO_DATETIME
          microsec = ($7.to_f * 1_000_000).to_i
          res = new_time $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, microsec
          res
        end
      end

      def fallback_string_to_date(string)
        begin
          ::Date.strptime(string, I18n.translate('date.formats.default'))
        rescue ArgumentError
          nil
        end
      end

      def fallback_string_to_time(string)
        time_hash = Date._parse(string)
        time_hash[:sec_fraction] = microseconds(time_hash)

        new_time(*time_hash.values_at(:year, :mon, :mday, :hour, :min, :sec, :sec_fraction))
      end
    end
  end
end
