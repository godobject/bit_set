# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2016

This file is part of BitSet.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
=end

module GodObject
  module BitSet

    # A bit set with named digits and numeric internal value 
    class BitSet

      # @return [Array<Symbol>] list of valid String representation formats
      #
      # @private
      STRING_FORMAT = Set[:long, :short].freeze

      # @return [GodObject::BitSet::Configuration] the configuration for the
      #   BitSet
      attr_reader :configuration

      # @return [Integer] the BitSet as binary number
      attr_reader :integer_representation

      extend Forwardable
      include Comparable

      # Initializes a new BitSet
      # 
      # @param [Integer, Array<Symbol>] state either the octal state of the
      #   BitSet or a list of enabled digits
      #
      # @param [GodObject::BitSet::Configuration] configuration the configuration
      #   which defines the digits of the BitSet
      def initialize(*state, configuration)
        @configuration = Configuration.build(configuration)

        create_attribute_readers

        if state.size == 1 && state.first.respond_to?(:to_int)
          @integer_representation = state.first.to_int
        else
          state = state.first if state.size == 1 && state.first.is_a?(Enumerable)

          state, invalid_tokens = state.flatten.partition do |token|
            digits.include?(token)
          end

          if invalid_tokens.any?
            string = invalid_tokens.map(&:inspect).join(', ')
            raise ArgumentError, "Invalid digit(s): #{string}"
          end

          @integer_representation = 0

          state.each do |digit|
            @integer_representation |= binary_position(digit)
          end
        end
      end

      # @return [{Symbol => true, false}] all digits and their current state
      def state
        state = {}

        digits.each do |digit|
          state[digit] = self[digit]
        end

        state
      end

      alias attributes state

      # @overload [](index)
      #   Returns the state of a digit selected by index.
      #   @param [Integer] index a digit index
      #   @return [true, false] the digit's current state
      #
      # @overload [](digit)
      #   Returns the state of a digit selected by name.
      #   @param [Symbol] digit a digit name
      #   @return [true, false] the digit's current state
      def [](index_or_digit)
        digit = find_digit(index_or_digit)

        case (@integer_representation & binary_position(digit)) >> digits.reverse.index(digit)
        when 1 then true
        else
          false
        end
      end

      # @return [Array<Symbol>] a list of all digits which are enabled
      def enabled_digits
        set = Set[]

        digits.each {|digit| set << digit if self[digit] }

        set
      end

      # @return [Array<Symbol>] a list of all digits which are disabled
      def disabled_digits
        set = Set[]

        digits.each {|digit| set << digit unless self[digit] }

        set
      end

      # @return [GodObject::BitSet] a new BitSet of the same configuration with
      #   all digit states inverted
      def invert
        @configuration.new(@configuration.valid_range.max - @integer_representation)
      end

      # @param [GodObject::BitSet, Array<Symbol>] other another
      #   BitSet
      # @return [GodObject::BitSet] a new BitSet with the enabled
      #   digits of the current and other
      def +(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        @configuration.new(enabled_digits + other)
      end

      # @param [GodObject::BitSet, Array<Symbol>] other another
      #   BitSet
      # @return [GodObject::BitSet] a new BitSet with the enabled
      #   digits of the current without the enabled of other
      def -(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        @configuration.new(enabled_digits - other)
      end

      # @param [GodObject::BitSet, Integer] other another BitSet
      # @return [GodObject::BitSet] a new BitSet with the enabled
      #   digits of the current and other
      def union(other)
        other = other.to_i if other.respond_to?(:to_i)

        @configuration.new(@integer_representation | other)
      end

      alias | union

      # @param [GodObject::BitSet, Integer] other another BitSet
      # @return [GodObject::BitSet] a new BitSet with only those
      #   digits enabled which are enabled in both the current and other
      def intersection(other)
        other = other.to_i if other.respond_to?(:to_i)

        @configuration.new(@integer_representation & other)
      end

      alias & intersection

      # @param [GodObject::BitSet, Integer] other another BitSet
      # @return [GodObject::BitSet] a new BitSet with only those enabled
      #   digits which are enabled in only one of current and other
      def symmetric_difference(other)
        other = other.to_i if other.respond_to?(:to_i)

        @configuration.new(@integer_representation ^ other)
      end

      alias ^ symmetric_difference

      # Compares the BitSet to another to determine its relative position.
      #
      # BitSets are only comparable if their configuration is equal. Relative
      # position is then defined by comparing the Integer representation.
      #
      # @param [GodObject::BitSet] other a BitSet
      # @return [-1, 0, 1, nil] -1 if other is greater, 0 if other is equal and
      #   1 if other is lesser than self, nil if comparison is impossible
      def <=>(other)
        if @configuration == other.configuration
          @integer_representation <=> other.integer_representation
        else
          nil
        end
      rescue NoMethodError
        nil
      end

      # Answers if another object is equal and of the same type family.
      #
      # @see GodObject::BitSet#<=>
      # @param [Object] other an object to be checked for equality
      # @return [true, false] true if the object is considered equal and of the
      #   same type familiy, false otherwise
      def eql?(other)
        self == other && other.kind_of?(self.class)
      end

      # @return [see Array#hash] identity hash for hash table usage
      def hash
        [@configuration, @integer_representation].hash
      end

      # Represents a BitSet as String for debugging.
      #
      # @return [String] a String representation for debugging
      def inspect
        "#<#{self.class}: #{self.to_s.inspect}>"
      end

      # Represents a BitSet as a binary Integer.
      #
      # @return [Integer] an Integer representation
      def to_i
        @integer_representation
      end

      # Represents a BitSet as String.
      #
      # @param [:long, :short] format the String format
      # @return [String] a String representation
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

        if @integer_representation == 0 && format == :short
          output << '-'
        end

        output
      end

      protected

      # @!method digits
      #   @attribute digits [readonly]
      #   @return (see GodObject::BitSet::Configuration#digits)
      #   @private
      #
      # @!method binary_position
      #   @return (see GodObject::BitSet::Configuration#binary_position)
      #   @private
      #
      # @!method enabled_character
      #   @return (see GodObject::BitSet::Configuration#enabled_character)
      #   @private
      #
      # @!method disabled_character
      #   @return (see GodObject::BitSet::Configuration#disabled_character)
      #   @private
      #
      # @!method find_digit
      #   @return (see GodObject::BitSet::Configuration#find_digit)
      #   @private
      #
      # @!method valid_range
      #   @attribute valid_range [readonly]
      #   @return (see GodObject::BitSet::Configuration#valid_range)
      #   @private
      def_delegators :@configuration,
        :digits, :binary_position, :enabled_character,
        :disabled_character, :find_digit, :valid_range

      # For each configured digit name, a reader method and a reader method with
      # a question mark suffix is generated to easily ask for the state of a
      # single digit.
      #
      # @private
      # @return [void]
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
end
