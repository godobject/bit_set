# encoding: UTF-8
=begin
Copyright Alexander E. Fischer <aef@raxys.net>, 2012-2013

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
  class BitSet

    # A Configuration defines the digits of a BitSet. Additionally it can hold
    # information on how to represent the digits in a String representation.
    class Configuration

      # @return [String] the default String representation for enabled digits
      UNNAMED_ENABLED  = '1'.freeze

      # @return [String] the default String representation for disabled digits
      UNNAMED_DISABLED = '0'.freeze

      # @return [String] the default String representation for disabled digits
      #   which have a custom enabled representation
      NAMED_DISABLED   = '-'.freeze

      class << self

        # @overload build(configuration)
        #   Returns an existing instance of GodObject::BitSet::Configuration.
        #   @param [GodObject::BitSet::Configuration] configuration an already
        #     existing Configuration
        #   @return [GodObject::BitSet::Configuration] the same Configuration object
        #
        # @overload build(digits)
        #   Returns a new Configuration object with given attributes.
        #   @param [Array<Symbol>] digits a list of digit names
        #   @return [GodObject::PosixMode::Mode] a new Configuration object
        #
        # @overload build(enabled_representations_by_digits)
        #   Returns a new Configuration object with given attributes.
        #   @param [Hash<Symbol => String>] enabled_representations_by_digits
        #     digit names mapped to their enabled character representations
        #   @return [GodObject::PosixMode::Mode] a new Configuration object
        #
        # @overload build(representations_by_digits)
        #   Returns a new Configuration object with given attributes.
        #   @param [Hash<Symbol => Array<String>>] representations_by_digits
        #     digit names mapped to their enabled and disabled character
        #     representations
        #   @return [GodObject::PosixMode::Mode] a new Configuration object
        def build(configuration)
          if configuration.is_a?(Configuration)
            configuration
          else
            new(configuration)
          end
        end

      end

      # @return [Integer] the Integer representation if all digits are enabled
      attr_reader :max

      # Initializes a new BitSet::Configuration
      # 
      # @overload initialize(digits)
      #   @param [Array<Symbol>] digits a list of digit names
      #
      # @overload initialize(enabled_representations_by_digits)
      #   @param [Hash<Symbol => String>] enabled_representations_by_digits
      #     digit names mapped to their enabled character representations
      #
      # @overload initialize(representations_by_digits)
      #   @param [Hash<Symbol => Array<String>>] representations_by_digits
      #     digit names mapped to their enabled and disabled character
      #     representations
      def initialize(configuration)
        @digits   = {}
        @enabled  = {}
        @disabled = {}

        configuration.each do |digit, display|
          digit = digit.to_sym

          @digits[digit] = nil

          case
          when display.respond_to?(:all?) && display.all?{|s| s.respond_to?(:to_str) && s.to_str.length == 1}
            @enabled[digit]  = display.first.to_str.dup.freeze
            @disabled[digit] = display.last.to_str.dup.freeze
          when display.respond_to?(:to_str) && display.to_str.length == 1
            @enabled[digit]  = display.to_str.dup.freeze
            @disabled[digit] = NAMED_DISABLED
          when display.nil?
            @enabled[digit]  = UNNAMED_ENABLED
            @disabled[digit] = UNNAMED_DISABLED
          else
            raise ArgumentError, 'Invalid configuration'
          end
        end

        raise ArgumentError, 'At least one digit must be configured' if digits.count < 1

        @digits.keys.reverse.each_with_index{|digit, index| @digits[digit] = 2 ** index }

        @max = (@digits.values.first * 2) - 1

        @unique_characters = !@enabled.values.dup.uniq!
      end

      # @attribute min [readonly]
      # @return [Integer] the Integer representation if all digits are disabled
      def min
        0
      end

      # Answers if all digits have unique enabled representations.
      #
      # @return [true, false] true if all digits have unique enabled
      #   representations, false otherwise
      def unique_characters?
        @unique_characters
      end

      # @attribute digits [readonly]
      # @return [Array<Symbol>] an ordered list of all configured digit names
      def digits
        @digits.keys
      end

      # @param [Integer, Array<Symbol>] state either the octal state of the
      #   BitSet or a list of enabled digits
      # @return [GodObject::BitSet] a new BitSet object with the current
      #   configuration
      def new(state)
        BitSet.new(state, self)
      end

      # @return [Integer] the Integer representation of a BitSet where
      #   only the given digit is enabled.
      def binary_position(digit)
        @digits[find_digit(digit)]
      end

      # @param [Symbol, Integer] digit the name or index of the digit
      # @return [String] the String representation for the given digit when
      #   it is disabled
      def disabled_character(digit)
        @disabled[find_digit(digit)]
      end

      # @param [Symbol, Integer] digit the name or index of the digit
      # @return [String] the String representation for the given digit when
      #   it is enabled
      def enabled_character(digit)
        @enabled[find_digit(digit)]
      end

      # @param [Symbol, Integer] index_or_digit the name or index of the digit
      # @return [Symbol] the digit's name
      def find_digit(index_or_digit)
        case
        when index_or_digit.respond_to?(:to_sym)
          digit = index_or_digit.to_sym

          raise ArgumentError, "Invalid digit name (#{index_or_digit})" unless @digits.keys.include?(digit)
        else
          digit = @digits.keys[index_or_digit.to_int]
        end

        raise ArgumentError, "Invalid index or digit (#{index_or_digit})" unless digit

        digit
      end

      # Answers if another object is equal.
      #
      # Equality is defined as having the same ordered list of digits.
      #
      # @param [Object] other an object to be checked for equality
      # @return [true, false] true if the object is considered equal, false
      #   otherwise
      def ==(other)
        digits == other.digits
      end

      # Answers if another object is equal and of the same type family.
      #
      # @see GodObject::Configuration#==
      # @param [Object] other an object to be checked for equality
      # @return [true, false] true if the object is considered equal and of
      #   the same type familiy, false otherwise
      def eql?(other)
        self == other && other.kind_of?(self.class)
      end

      # @return (see Hash#hash) identity hash for hash table usage
      def hash
        @digits.hash
      end

    end

  end
end
