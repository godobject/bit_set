require 'set'
require 'forwardable'

require 'god_object/bit_set/version'
require 'god_object/bit_set/configuration'

module GodObject

  class BitSet
    STRING_FORMAT = Set[:long, :short].freeze

    attr_reader :configuration, :state

    extend Forwardable
    include Comparable

    def initialize(state = 0, configuration)
      @configuration = Configuration.build(configuration)

      create_attribute_readers

      case
      when state.respond_to?(:to_int)
        @state = state.to_int
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

    alias attributes state

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
      @configuration.new(@configuration.max - @state)
    end

    def +(other)
      other = other.enabled_digits if other.respond_to?(:enabled_digits)

      @configuration.new(enabled_digits + other)
    end

    def -(other)
      other = other.enabled_digits if other.respond_to?(:enabled_digits)

      @configuration.new(enabled_digits - other)
    end

    def union(other)
      other = other.state if other.respond_to?(:state)

      @configuration.new(@state | other)
    end

    alias | union

    def intersection(other)
      other = other.state if other.respond_to?(:state)

      @configuration.new(@state & other)
    end

    alias & intersection

    def symmetric_difference(other)
      other = other.state if other.respond_to?(:state)

      @configuration.new(@state ^ other)
    end

    alias ^ symmetric_difference

    def <=>(other)
      if @configuration == other.configuration
        @state <=> other.state
      else
        nil
      end
    rescue NoMethodError
      nil
    end

    def eql?(other)
      self == other && other.kind_of?(self.class)
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
        raise ArgumentError, 'Short format only available for configurations with unique characters for each digit'
      end

      output = ''

      attributes.each do |digit, value|
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

    protected

    def_delegators :@configuration,
      :digits, :binary_position, :enabled_character,
      :disabled_character, :find_digit

    def create_attribute_readers
      bit_set = self

      singleton_class.class_eval do
        bit_set.digits.each do |digit|
          define_method("#{digit}?") do
            bit_set[digit]
          end

          alias :"#{digit}" :"#{digit}?"
        end
      end
    end

  end

end
