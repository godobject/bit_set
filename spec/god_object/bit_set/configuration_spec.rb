# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2014

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
    describe Configuration do

      let(:traffic_light_configuration) { Configuration.new(red: 'r', yellow: 'y', green: 'g') }
      let(:generic_configuration) { Configuration.new([:a, :b, :c, :d, :e])}

      describe ".build" do
        it "should pass-through already existing Configuration objects" do
          configuration = Configuration.new([:test, :fnord])

          expect(Configuration.build(configuration)).to equal configuration
        end
      end

      describe ".new" do
        it "should complain about an empty list" do
          expect {
            Configuration.new([])
          }.to raise_error(ArgumentError, 'At least one digit must be configured')
        end

        it "should handle a list of digit names" do
          configuration = Configuration.new([:first, :second, :third])

          expect(configuration.digits).to eql [:first, :second, :third]
          expect(configuration.enabled_character(:first)).to   eql '1'
          expect(configuration.disabled_character(:first)).to  eql '0'
          expect(configuration.enabled_character(:second)).to  eql '1'
          expect(configuration.disabled_character(:second)).to eql '0'
          expect(configuration.enabled_character(:third)).to   eql '1'
          expect(configuration.disabled_character(:third)).to  eql '0'
        end

        it "should handle a hash of digit names and their enabled representation" do
          configuration = Configuration.new(first: 'f', second: 's', third: 't')

          expect(configuration.digits).to eql [:first, :second, :third]
          expect(configuration.enabled_character(:first)).to   eql 'f'
          expect(configuration.disabled_character(:first)).to  eql '-'
          expect(configuration.enabled_character(:second)).to  eql 's'
          expect(configuration.disabled_character(:second)).to eql '-'
          expect(configuration.enabled_character(:third)).to   eql 't'
          expect(configuration.disabled_character(:third)).to  eql '-'
        end

        it "should handle a hash of digit names and both their enabled and disabled representations" do
          configuration = Configuration.new(first: ['f', '1'], second: ['s', '2'], third: ['t', '3'])

          expect(configuration.digits).to eql [:first, :second, :third]
          expect(configuration.enabled_character(:first)).to   eql 'f'
          expect(configuration.disabled_character(:first)).to  eql '1'
          expect(configuration.enabled_character(:second)).to  eql 's'
          expect(configuration.disabled_character(:second)).to eql '2'
          expect(configuration.enabled_character(:third)).to   eql 't'
          expect(configuration.disabled_character(:third)).to  eql '3'
        end

        it "should complain about multi-character enabled representations" do
          expect {
            Configuration.new(first: ['f', '1'], second: ['ss', '2'], third: ['t', '3'])
          }.to raise_error(ArgumentError, 'Invalid configuration')
        end

        it "should complain about multi-character disabled representations" do
          expect {
            Configuration.new(first: ['f', '1'], second: ['s', '22'], third: ['t', '3'])
          }.to raise_error(ArgumentError, 'Invalid configuration')
        end

        it "should complain about non String-like enabled representations" do
          expect {
            Configuration.new(first: ['f', '1'], second: [2, '2'], third: ['t', '3'])
          }.to raise_error(ArgumentError, 'Invalid configuration')
        end

        it "should complain about non String-like disabled representations" do
          expect {
            Configuration.new(first: ['f', '1'], second: ['s', 2], third: ['t', '3'])
          }.to raise_error(ArgumentError, 'Invalid configuration')
        end
      end

      describe "#valid_range" do
        it "should return the Range in which an Integer representation of a BitSet of this Configuration can be" do
          expect(traffic_light_configuration.valid_range).to eql 0..7
          expect(generic_configuration.valid_range).to eql 0..31
        end
      end

      describe "#unique_characters?" do
        it "should return true if every digit has a unique character representing it" do
          expect(traffic_light_configuration.unique_characters?).to eq true
        end

        it "should return false if multiple digits have the same characters representing it" do
          expect(generic_configuration.unique_characters?).to eq false
        end
      end

      describe "#digits" do
        it "should return an ordered list of all valid digits' symbols" do
          expect(traffic_light_configuration.digits).to eql [:red, :yellow, :green]
          expect(generic_configuration.digits).to eql [:a, :b, :c, :d, :e]
        end
      end

      describe "#new" do
        it "should create a new BitSet with this configuration" do
          result = traffic_light_configuration.new(7)

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 7
          expect(result.configuration).to eql traffic_light_configuration
        end
      end

      describe "#binary_position" do
        it "should return the given digit's positional value (given as Symbol)" do
          expect(traffic_light_configuration.binary_position(:red)).to eql 4
          expect(generic_configuration.binary_position(:b)).to eql 8
        end

        it "should return the given digit's positional value (given as index)" do
          expect(traffic_light_configuration.binary_position(0)).to eql 4
          expect(generic_configuration.binary_position(1)).to eql 8
        end
      end

      describe "#enabled_character" do
        it "should return the character that represents the given digits when on (given by Symbol)" do
          expect(traffic_light_configuration.enabled_character(:yellow)).to eql 'y'
          expect(generic_configuration.enabled_character(4)).to eql '1'
        end
      end

      describe "#disabled_characters" do
        it "should return the character that represents the given digits when on (given by Symbol)" do
          expect(traffic_light_configuration.disabled_character(:green)).to eql '-'
          expect(generic_configuration.disabled_character(1)).to eql '0'
        end
      end

      describe "#find_digit" do
        pending
      end

      describe "#==" do
        it "should return true if digits and representation are equal" do
          configuration = Configuration.new(red: 'r', yellow: 'y', green: 'g')

          expect(traffic_light_configuration).to eq(configuration)
        end

        it "should return true if only digits are equal" do
          configuration = Configuration.new([:red, :yellow, :green])

          expect(traffic_light_configuration).to eq(configuration)
        end

        it "should return true if only digits are equal (different class)" do
          configuration = OpenStruct.new
          configuration.digits = [:red, :yellow, :green]

          expect(traffic_light_configuration).to eq(configuration)
        end

        it "should return false if digits differ" do
          configuration = Configuration.new([:yellow, :red, :green])

          expect(traffic_light_configuration).not_to eq(configuration)
        end

        it "should return false if compared to incompatible type" do
          expect(traffic_light_configuration).not_to eq(:incompatible)
        end
      end

      describe "#eql?" do
        it "should return true if digits and representation are equal" do
          configuration = Configuration.new(red: 'r', yellow: 'y', green: 'g')

          expect(traffic_light_configuration).to eql(configuration)
        end

        it "should return true if only digits are equal" do
          configuration = Configuration.new([:red, :yellow, :green])

          expect(traffic_light_configuration).to eql(configuration)
        end

        it "should return false if digits are equal but different class" do
          configuration = OpenStruct.new
          configuration.digits = [:red, :yellow, :green]

          expect(traffic_light_configuration).not_to eql(configuration)
        end

        it "should return false if digits differ" do
          configuration = Configuration.new([:yellow, :red, :green])

          expect(traffic_light_configuration).not_to eql(configuration)
        end

        it "should return false if compared to incompatible type" do
          expect(traffic_light_configuration).not_to eql(:incompatible)
        end
      end

      describe "#hash" do
        it "should be stable over multiple calls" do
          expect(generic_configuration.hash).to eql generic_configuration.hash
        end

        it "should differ if the digits differ" do
          configuration = Configuration.new([:a, :b, :c, :d, :x])

          expect(generic_configuration.hash).not_to eql configuration.hash
        end

        it "should not differ if only the representation differs" do
          configuration = Configuration.new([:red, :yellow, :green])

          expect(traffic_light_configuration.hash).to eql configuration.hash
        end
      end

    end
  end
end
