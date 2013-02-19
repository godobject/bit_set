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

    end

    describe "#==" do

    end

    describe "#eql?" do

    end

    describe "#hash" do

    end

  end
end
