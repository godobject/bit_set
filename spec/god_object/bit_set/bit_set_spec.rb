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

require 'spec_helper'

module GodObject
  module BitSet
    describe BitSet do

      let(:traffic_light_configuration) { Configuration.new(red: 'r', yellow: 'y', green: 'g') }
      let(:generic_configuration) { Configuration.new([:a, :b, :c, :d, :e])}

      describe ".new" do
        it "should accept a configuration" do
          result = BitSet.new(generic_configuration)

          result.should be_a(BitSet)
          result.to_i.should eql 0
          result.configuration.should eql generic_configuration
        end

        it "should accept an Integer as initial state and a configuration" do
          result = BitSet.new(0b01010, generic_configuration)

          result.should be_a(BitSet)
          result.to_i.should eql 0b01010
          result.configuration.should eql generic_configuration
        end

        it "should accept multiple arguments of enabled digits as initial state and a configuration" do
          result = BitSet.new(:red, :green, traffic_light_configuration)

          result.should be_a(BitSet)
          result.to_i.should eql 0b101
          result.configuration.should eql traffic_light_configuration
        end

        it "should accept a list of enabled digits as initial state and a configuration" do
          result = BitSet.new(Set[:red, :green], traffic_light_configuration)

          result.should be_a(BitSet)
          result.to_i.should eql 0b101
          result.configuration.should eql traffic_light_configuration
        end

        it "should accept on-the-fly configurations" do
          result = BitSet.new(Set[:symmetric, :transitive], symmetric: nil, transitive: 't', antisymmetric: ['a', 'x'])

          configuration = Configuration.build(symmetric: nil, transitive: 't', antisymmetric: ['a', 'x'])

          result.should be_a(BitSet)
          result.to_i.should eql 0b110
          result.to_s.should eql "1tx"
          result.configuration.should eql configuration
        end

        it "should complain about invalid digits" do
          expect {
            BitSet.new(Set[:white, :blue, :green], traffic_light_configuration)
          }.to raise_error(ArgumentError, "Invalid digit(s): :white, :blue")
        end

        it "should complain about invalid state" do
          expect {
            BitSet.new(:invalid, traffic_light_configuration)
          }.to raise_error(ArgumentError, "Invalid digit(s): :invalid")
        end

        it "should complain about invalid configuration" do
          expect {
            BitSet.new(3, invalid: 12)
          }.to raise_error(ArgumentError, 'Invalid configuration')
        end
      end

      context "magic attributes" do
        it "should allow accessing each digit's on/off state by name" do
          bit_set = BitSet.new(0b001, traffic_light_configuration)

          bit_set.red.should be_false
          bit_set.yellow.should be_false
          bit_set.green.should be_true
        end

        it "should allow accessing each digit's on/off state by a question mark method" do
          bit_set = BitSet.new(0b01101, generic_configuration)

          bit_set.a?.should be_false
          bit_set.b?.should be_true
          bit_set.c?.should be_true
          bit_set.d?.should be_false
          bit_set.e?.should be_true
        end

        it "should complain about invalid methods as usual" do
          expect {
            BitSet.new(0b101, traffic_light_configuration).fnord
          }.to raise_error(NoMethodError, /^undefined method `fnord'/)
        end
      end

      [:state, :attributes].each do |method_name|
        describe "##{method_name}" do
          it "should list all digits and their on/off state" do
            bit_set = BitSet.new(0b10101, generic_configuration)
    
            bit_set.public_send(method_name).should eql(
              a: true,
              b: false,
              c: true,
              d: false,
              e: true
            )
          end
        end
      end

      describe "#to_i" do
        it "should return the Integer state" do
          bit_set = BitSet.new(6, traffic_light_configuration)

          bit_set.to_i.should eql 6
        end
      end

      describe "#[]" do
        it "should return true if the digit given by symbol is on" do
          bit_set = BitSet.new(0b100, traffic_light_configuration)

          bit_set[:red].should be_true
        end

        it "should return true if the digit given by index is on" do
          bit_set = BitSet.new(0b100, traffic_light_configuration)

          bit_set[0].should be_true
        end

        it "should return false if the digit given by symbol is off" do
          bit_set = BitSet.new(0b11101, generic_configuration)

          bit_set[:d].should be_false
        end

        it "should return false if the digit given by index is off" do
          bit_set = BitSet.new(0b11101, generic_configuration)

          bit_set[3].should be_false
        end
      end

      describe "#enabled_digits" do
        it "should return the set of digits which are on" do
          bit_set = BitSet.new(0b10101, generic_configuration)

          bit_set.enabled_digits.should eql Set[:a, :c, :e]
        end
      end

      describe "#disabled_digits" do
        it "should return the set of digits which are off" do
          bit_set = BitSet.new(0b001, traffic_light_configuration)

          bit_set.disabled_digits.should eql Set[:red, :yellow]
        end
      end

      describe "#invert" do
        it "should return a copy with every digit on/off state toggled" do
          bit_set = BitSet.new(0b101, traffic_light_configuration)

          result = bit_set.invert
          result.should be_a(BitSet)
          result.configuration.should eql traffic_light_configuration
          result.to_i.should eql 0b010
          result.should_not equal bit_set
        end
      end

      describe "#+" do
        it "should return a copy with all added digits switched to on (given a BitSet)" do
          bit_set = BitSet.new(0b01000, generic_configuration)

          result = bit_set + BitSet.new([:a, :d], generic_configuration)

          result.should be_a(BitSet)
          result.configuration.should eql generic_configuration
          result.to_i.should eql 0b11010
          result.should_not equal bit_set
        end

        it "should return a copy with all added digits switched to on (given an Enumerable)" do
          bit_set = BitSet.new(0b01010, generic_configuration)

          result = bit_set + Set[:a, :d]

          result.should be_a(BitSet)
          result.configuration.should eql generic_configuration
          result.to_i.should eql 0b11010
          result.should_not equal bit_set
        end
      end

      describe "#-" do
        it "should return a copy with all added digits switched to on (given a BitSet)" do
          bit_set = BitSet.new(0b110, traffic_light_configuration)

          result = bit_set - BitSet.new([:yellow, :green], traffic_light_configuration)

          result.should be_a(BitSet)
          result.configuration.should eql traffic_light_configuration
          result.to_i.should eql 0b100
          result.should_not equal bit_set
        end

        it "should return a copy with all added digits switched to on (given an Enumerable)" do
          bit_set = BitSet.new(0b101, traffic_light_configuration)

          result = bit_set - [:red, :yellow]

          result.should be_a(BitSet)
          result.configuration.should eql traffic_light_configuration
          result.to_i.should eql 0b001
          result.should_not equal bit_set
        end
      end

      [:union, :|].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with all enabled digits of both operands switched to on (given a BitSet)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:d, :e], generic_configuration))

            result.should be_a(BitSet)
            result.configuration.should eql generic_configuration
            result.to_i.should eql 0b01111
            result.should_not equal bit_set
          end

          it "should return a copy with all enabled digits of both operands switched to on (given an Integer)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name, 0b00011)

            result.should be_a(BitSet)
            result.configuration.should eql generic_configuration
            result.to_i.should eql 0b01111
            result.should_not equal bit_set
          end
        end
      end

      [:intersection, :&].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with only those digits switched to on which are on in both operands (given a BitSet)" do
            bit_set = BitSet.new(0b110, traffic_light_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:yellow, :green], traffic_light_configuration))

            result.should be_a(BitSet)
            result.configuration.should eql traffic_light_configuration
            result.to_i.should eql 0b010
            result.should_not equal bit_set
          end

          it "should return a copy with only those digits switched to on which are on in both operands (given an Integer)" do
            bit_set = BitSet.new(0b110, traffic_light_configuration)

            result = bit_set.public_send(method_name, 0b011)

            result.should be_a(BitSet)
            result.configuration.should eql traffic_light_configuration
            result.to_i.should eql 0b010
            result.should_not equal bit_set
          end
        end
      end

      [:symmetric_difference, :^].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with only those digits switched to on which are uniquely enabled in both operands (given a BitSet)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:d, :e], generic_configuration))

            result.should be_a(BitSet)
            result.configuration.should eql generic_configuration
            result.to_i.should eql 0b01110
            result.should_not equal bit_set
          end

          it "should return a copy with only those digits switched to on which are uniquely enabled in both operands (given an Integer)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name, 0b00011)

            result.should be_a(BitSet)
            result.configuration.should eql generic_configuration
            result.to_i.should eql 0b01110
            result.should_not equal bit_set
          end
        end
      end

      describe "#==" do
        let(:bit_set) { BitSet.new(0b110, traffic_light_configuration) }

        it "should return true if state and configuration is equal" do
          bit_set.should == BitSet.new(0b110, traffic_light_configuration)
        end

        it "should return true if state and configuration is equal (different class)" do
          bit_set.should == OpenStruct.new(integer_representation: 0b110, configuration: traffic_light_configuration)
        end

        it "should return false if state is equal but configuration differs" do
          bit_set.should_not == BitSet.new(0b110, generic_configuration)
        end

        it "should return false if configuration is equal but state differs" do
          bit_set.should_not == BitSet.new(0b010, traffic_light_configuration)
        end

        it "should return false if both state and configuration differ" do
          bit_set.should_not == BitSet.new(0b010, generic_configuration)
        end

        it "should return false if compared to incompatible type" do
          bit_set.should_not == :incompatible
        end
      end

      describe "#eql?" do
        let(:bit_set) { BitSet.new(0b110, traffic_light_configuration) }

        it "should return true if state and configuration is equal" do
          bit_set.should eql BitSet.new(0b110, traffic_light_configuration)
        end

        it "should return false if state and configuration is equal (different class)" do
          bit_set.should_not eql OpenStruct.new(integer_representation: 0b110, configuration: traffic_light_configuration)
        end

        it "should return false if state is equal but configuration differs" do
          bit_set.should_not eql BitSet.new(0b110, generic_configuration)
        end

        it "should return false if configuration is equal but state differs" do
          bit_set.should_not eql BitSet.new(0b010, traffic_light_configuration)
        end

        it "should return false if both state and configuration differ" do
          bit_set.should_not eql BitSet.new(0b010, generic_configuration)
        end

        it "should return false if compared to an incompatible object" do
          bit_set.should_not eql :incompatible
        end
      end

      describe "#<=>" do
        let(:bit_set) { BitSet.new(11, generic_configuration) }

        it "should return -1 if state is lower than that of the compared" do
          (bit_set <=> BitSet.new(12, generic_configuration)).should eql -1
        end

        it "should return 0 if state is equal to that of the compared" do
          (bit_set <=> BitSet.new(11, generic_configuration)).should eql 0
        end

        it "should return 1 if state is higher than that of the compared" do
          (bit_set <=> BitSet.new(10, generic_configuration)).should eql 1
        end

        it "should return nil if configuration differs" do
          (bit_set <=> BitSet.new(11, traffic_light_configuration)).should be_nil
        end

        it "should return nil if compared to an incompatible object" do
          (bit_set <=> :incompatible).should be_nil
        end

        it "should make BitSet sortable" do
          result = [BitSet.new(11, generic_configuration),
                    BitSet.new(10, generic_configuration),
                    BitSet.new(12, generic_configuration)].sort

          result.should eql [
            BitSet.new(10, generic_configuration),
            BitSet.new(11, generic_configuration),
            BitSet.new(12, generic_configuration)
          ]
        end
      end

      describe "#hash" do
        let(:bit_set) { BitSet.new(0b01011, generic_configuration) }

        it "should be stable over multiple calls" do
          bit_set.hash.should eql bit_set.hash
        end

        it "should differ if state is equal but configuration differs" do
          bit_set.hash.should_not eql BitSet.new(0b01011, traffic_light_configuration).hash
        end

        it "should differ if configuration is equal but state differs" do
          bit_set.hash.should_not eql BitSet.new(0b00010, generic_configuration).hash
        end

        it "should differ if both state and configuration differ" do
          bit_set.hash.should_not eql BitSet.new(0b00010, traffic_light_configuration).hash
        end
      end

      describe "#inspect" do
        it "should return a decent string representation for debugging" do
          result = BitSet.new(0b011, traffic_light_configuration).inspect

          result.should eql '#<GodObject::BitSet::BitSet: "-yg">'
        end
      end

      describe "#to_s" do
        it "should complain about invalid formats" do
          expect {
            BitSet.new(0b00101, generic_configuration).to_s(:medium)
          }.to raise_error(ArgumentError, "Invalid format: :medium")
        end

        context "long mode" do
          it "should by default display every digit as either 0 or 1" do
            result = BitSet.new(0b00101, generic_configuration).to_s

            result.should eql "00101"
          end

          it "should display every digit as either it's assigned character or a dash if digits have assigned characters" do
            result = BitSet.new(0b101, traffic_light_configuration).to_s

            result.should eql "r-g"
          end
        end

        context "short mode" do
          it "should not be available if configuration has no unique characters per digit" do
            expect {
              BitSet.new(3, generic_configuration).to_s(:short)
            }.to raise_error(ArgumentError, 'Short format only available for configurations with unique characters for each digit')
          end

          it "should only display enabled digits" do
            result = BitSet.new(0b110, traffic_light_configuration).to_s(:short)

            result.should eql "ry"
          end

          it "should diplay one dash when no digit is on" do
            result = BitSet.new(0, traffic_light_configuration).to_s(:short)

            result.should eql "-"
          end
        end
      end

    end
  end
end
