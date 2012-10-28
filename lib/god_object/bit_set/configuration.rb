# encoding: UTF-8

module GodObject
  class BitSet

    class Configuration
       UNNAMED_ENABLED  = '1'.freeze
       UNNAMED_DISABLED = '0'.freeze
       NAMED_DISABLED   = '-'.freeze

       class << self

         def build(configuration)
           if configuration.is_a?(Configuration)
             configuration
           else
             new(configuration)
           end
         end

       end

       attr_reader :max

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

       def min
         0
       end

       def unique_characters?
         @unique_characters
       end

       def digits
         @digits.keys
       end

       def new(*state)
         state.flatten!
         state = state[0] if state.length == 1 && state[0].respond_to?(:to_int)

         BitSet.new(state, self)
       end

       def binary_position(digit)
         @digits[find_digit(digit)]
       end

       def disabled_character(digit)
         @disabled[find_digit(digit)]
       end

       def enabled_character(digit)
         @enabled[find_digit(digit)]
       end

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

       def eql?(other)
         @digits == other.digits && other.kind_of?(self.class)
       end

       alias == eql?

       def hash
         @digits.hash
       end

     end

  end
end