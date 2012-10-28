require 'set'

require 'god_object/bit_set/version'
require 'god_object/bit_set/configuration'

module GodObject

  class BitSet
    STRING_FORMAT = Set[:long, :short].freeze

    attr_reader :configuration

    def initialize(state = 0, configuration)
      @configuration = Configuration.build(configuration)

      case
      when state.respond_to?(:to_int)
        @state = state.to_int
      when state[0].respond_to?(:to_int)
        @state = state[0].to_int
      else
        state, invalid_tokens = state.partition do |token|
          digits.include?(token)
        end

        if invalid_tokens.any?
          string = invalid_tokens.map(&:inspect).join(', ')
          raise ArgumentError, "Invalid digit(s): #{string}"
        end

        @state = 0

        state.each do |digit|
          @state |= binary_position(digit)
        end
      end
    end

    def state
      state = {}

      digits.each do |digit|
        state[digit] = self[digit]
      end

      state
    end

    def [](index_or_digit)
      digit = find_digit(index_or_digit)

      case (@state & binary_position(digit)) >> digits.reverse.index(digit)
      when 1 then true
      else
        false
      end
    end

    def enabled_digits
      set = Set[]

      digits.each {|digit| set << digit if self[digit] }

      set
    end

    def disabled_digits
      set = Set[]

      digits.each {|digit| set << digit unless self[digit] }

      set
    end

    def invert
      @configuration.new(@state, @configuration)
    end

    def &(other)
      @configuration.new(
        @state & (other.kind_of?(self.class) ? other.to_i : other.to_int)
      )
    end

    def |(other)
      @configuration.new(
        @state | (other.kind_of?(self.class) ? other.to_i : other.to_int)
      )
    end

    def ^(other)
      @configuration.new(
        @state ^ (other.kind_of?(self.class) ? other.to_i : other.to_int)
      )
    end

    def ==(other)
      to_i == other.to_i && @configuration == other.configuration
    rescue NoMethodError
      false
    end

    def eql?(other)
      self == other && other.kind_of?(self.class)
    rescue NoMethodError
      false
    end

    def <=>(other)
      @state <=> other.to_i
    end

    def hash
      [@configuration, @state].hash
    end

    def inspect
      "#<#{self.class}: #{self.to_s.inspect}>"
    end

    def to_s(format = :long)
      unless STRING_FORMAT.include?(format)
        raise ArgumentError, "Invalid format: #{format.inspect}"
      end

      if format == :short && !@configuration.unique_characters?
        raise ArgumentError, 'Short mode only available for configurations with unique characters for each digit'
      end

      output = ''

      state.each do |digit, value|
        case value
        when true
          output << enabled_character(digit)
        else
          output << disabled_character(digit) if format == :long
        end
      end

      if @state == 0 && format == :short
        output << '-'
      end

      output
    end

    def to_i
      @state
    end

    protected

    def digits
      @configuration.digits
    end

    def binary_position(digit)
      @configuration.binary_position(digit)
    end

    def enabled_character(digit)
      @configuration.enabled_character(digit)
    end

    def disabled_character(digit)
      @configuration.disabled_character(digit)
    end

    def find_digit(index_or_digit)
      @configuration.find_digit(index_or_digit)
    end

    def method_missing(name, *arguments)
      result = /^(?<digit>[A-Za-z]+)\??$/.match(name)

      if result && arguments.empty? && find_digit(result[:digit])
        self[result[:digit]]
      else
        raise ArgumentError
      end
    rescue ArgumentError
      raise NoMethodError, "undefined method '#{name}'"
    end

  end
end