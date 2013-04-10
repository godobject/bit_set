# encoding: UTF-8

require 'spec_helper'

module GodObject
  describe BitSet::Configuration do

    let(:traffic_light_configuration) { BitSet::Configuration.new(red: 'r', yellow: 'y', green: 'g') }
    let(:generic_configuration) { BitSet::Configuration.new([:a, :b, :c, :d, :e])}

    describe ".build" do
      it "should pass-through already existing Configuration objects" do
        configuration = BitSet::Configuration.new([:test, :fnord])

        BitSet::Configuration.build(configuration).should equal configuration
      end
    end

    describe ".new" do
      it "should complain about an empty list" do
        expect {
          BitSet::Configuration.new([])
        }.to raise_error(ArgumentError, 'At least one digit must be configured')
      end

      it "should handle a list of digit names" do
        configuration = BitSet::Configuration.new([:first, :second, :third])

        configuration.digits.should eql [:first, :second, :third]
        configuration.enabled_character(:first).should   eql '1'
        configuration.disabled_character(:first).should  eql '0'
        configuration.enabled_character(:second).should  eql '1'
        configuration.disabled_character(:second).should eql '0'
        configuration.enabled_character(:third).should   eql '1'
        configuration.disabled_character(:third).should  eql '0'
      end

      it "should handle a hash of digit names and their enabled representation" do
        configuration = BitSet::Configuration.new(first: 'f', second: 's', third: 't')

        configuration.digits.should eql [:first, :second, :third]
        configuration.enabled_character(:first).should   eql 'f'
        configuration.disabled_character(:first).should  eql '-'
        configuration.enabled_character(:second).should  eql 's'
        configuration.disabled_character(:second).should eql '-'
        configuration.enabled_character(:third).should   eql 't'
        configuration.disabled_character(:third).should  eql '-'
      end

      it "should handle a hash of digit names and both their enabled and disabled representations" do
        configuration = BitSet::Configuration.new(first: ['f', '1'], second: ['s', '2'], third: ['t', '3'])

        configuration.digits.should eql [:first, :second, :third]
        configuration.enabled_character(:first).should   eql 'f'
        configuration.disabled_character(:first).should  eql '1'
        configuration.enabled_character(:second).should  eql 's'
        configuration.disabled_character(:second).should eql '2'
        configuration.enabled_character(:third).should   eql 't'
        configuration.disabled_character(:third).should  eql '3'
      end

      it "should complain about multi-character enabled representations" do
        expect {
          BitSet::Configuration.new(first: ['f', '1'], second: ['ss', '2'], third: ['t', '3'])
        }.to raise_error(ArgumentError, 'Invalid configuration')
      end

      it "should complain about multi-character disabled representations" do
        expect {
          BitSet::Configuration.new(first: ['f', '1'], second: ['s', '22'], third: ['t', '3'])
        }.to raise_error(ArgumentError, 'Invalid configuration')
      end

      it "should complain about non String-like enabled representations" do
        expect {
          BitSet::Configuration.new(first: ['f', '1'], second: [2, '2'], third: ['t', '3'])
        }.to raise_error(ArgumentError, 'Invalid configuration')
      end

      it "should complain about non String-like disabled representations" do
        expect {
          BitSet::Configuration.new(first: ['f', '1'], second: ['s', 2], third: ['t', '3'])
        }.to raise_error(ArgumentError, 'Invalid configuration')
      end
    end

    describe "#min" do
      it "should return the minimum Integer state for BitSets of the Configuration (always 0)" do
        traffic_light_configuration.min.should eql 0
        generic_configuration.min.should eql 0
      end
    end

    describe "#max" do
      it "should return the maximum Integer state for BitSets of the Configuration" do
        traffic_light_configuration.max.should eql 7
        generic_configuration.max.should eql 31
      end
    end

    describe "#unique_characters?" do
      it "should return true if every digit has a unique character representing it" do
        traffic_light_configuration.unique_characters?.should be_true
      end

      it "should return false if multiple digits have the same characters representing it" do
        generic_configuration.unique_characters?.should be_false
      end
    end

    describe "#digits" do
      it "should return an ordered list of all valid digits' symbols" do
        traffic_light_configuration.digits.should eql [:red, :yellow, :green]
        generic_configuration.digits.should eql [:a, :b, :c, :d, :e]
      end
    end

    describe "#new" do
      it "should create a new BitSet with this configuration" do
        result = traffic_light_configuration.new(7)

        result.should be_a(BitSet)
        result.to_i.should eql 7
        result.configuration.should eql traffic_light_configuration
      end
    end

    describe "#binary_position" do
      it "should return the given digit's positional value (given as Symbol)" do
        traffic_light_configuration.binary_position(:red).should eql 4
        generic_configuration.binary_position(:b).should eql 8
      end

      it "should return the given digit's positional value (given as index)" do
        traffic_light_configuration.binary_position(0).should eql 4
        generic_configuration.binary_position(1).should eql 8
      end
    end

    describe "#enabled_character" do
      it "should return the character that represents the given digits when on (given by Symbol)" do
        traffic_light_configuration.enabled_character(:yellow).should eql 'y'
        generic_configuration.enabled_character(4).should eql '1'
      end
    end

    describe "#disabled_characters" do
      it "should return the character that represents the given digits when on (given by Symbol)" do
        traffic_light_configuration.disabled_character(:green).should eql '-'
        generic_configuration.disabled_character(1).should eql '0'
      end
    end

    describe "#find_digit" do
      pending
    end

    describe "#==" do
      it "should return true if digits and representation are equal" do
        configuration = BitSet::Configuration.new(red: 'r', yellow: 'y', green: 'g')

        traffic_light_configuration.should == configuration
      end

      it "should return true if only digits are equal" do
        configuration = BitSet::Configuration.new([:red, :yellow, :green])

        traffic_light_configuration.should == configuration
      end

      it "should return true if only digits are equal (different class)" do
        configuration = OpenStruct.new
        configuration.digits = [:red, :yellow, :green]

        traffic_light_configuration.should == configuration
      end

      it "should return false if state is equal but configuration differs" do
        pending
        bit_set.should_not == BitSet.new(0b110, generic_configuration)
      end

      it "should return false if configuration is equal but state differs" do
        pending
        bit_set.should_not == BitSet.new(0b010, traffic_light_configuration)
      end

      it "should return false if both state and configuration differ" do
        pending
        bit_set.should_not == BitSet.new(0b010, generic_configuration)
      end

      it "should return false if compared to incompatible type" do
        pending
        bit_set.should_not == :incompatible
      end
    end

    describe "#eql?" do
      pending
    end

    describe "#hash" do
      it "should be stable over multiple calls" do
        generic_configuration.hash.should eql generic_configuration.hash
      end

      it "should differ if the digits differ" do
        configuration = BitSet::Configuration.new([:e, :d, :c, :b, :a])

        generic_configuration.hash.should_not eql configuration.hash
      end

      it "should not differ if only the representation differs" do
        configuration = BitSet::Configuration.new([:red, :yellow, :green])

        traffic_light_configuration.hash.should eql configuration.hash
      end
    end

  end
end