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
    describe BitSet do

      let(:traffic_light_configuration) { Configuration.new(red: 'r', yellow: 'y', green: 'g') }
      let(:generic_configuration) { Configuration.new([:a, :b, :c, :d, :e])}

      describe ".new" do
        it "should accept a configuration" do
          result = BitSet.new(generic_configuration)

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 0
          expect(result.configuration).to eql generic_configuration
        end

        it "should accept an Integer as initial state and a configuration" do
          result = BitSet.new(0b01010, generic_configuration)

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 0b01010
          expect(result.configuration).to eql generic_configuration
        end

        it "should accept multiple arguments of enabled digits as initial state and a configuration" do
          result = BitSet.new(:red, :green, traffic_light_configuration)

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 0b101
          expect(result.configuration).to eql traffic_light_configuration
        end

        it "should accept a list of enabled digits as initial state and a configuration" do
          result = BitSet.new(Set[:red, :green], traffic_light_configuration)

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 0b101
          expect(result.configuration).to eql traffic_light_configuration
        end

        it "should accept on-the-fly configurations" do
          result = BitSet.new(Set[:symmetric, :transitive], symmetric: nil, transitive: 't', antisymmetric: ['a', 'x'])

          configuration = Configuration.build(symmetric: nil, transitive: 't', antisymmetric: ['a', 'x'])

          expect(result).to be_a(BitSet)
          expect(result.to_i).to eql 0b110
          expect(result.to_s).to eql "1tx"
          expect(result.configuration).to eql configuration
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

          expect(bit_set.red).to eq false
          expect(bit_set.yellow).to eq false
          expect(bit_set.green).to eq true
        end

        it "should allow accessing each digit's on/off state by a question mark method" do
          bit_set = BitSet.new(0b01101, generic_configuration)

          expect(bit_set.a?).to eq false
          expect(bit_set.b?).to eq true
          expect(bit_set.c?).to eq true
          expect(bit_set.d?).to eq false
          expect(bit_set.e?).to eq true
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
    
            expect(bit_set.public_send(method_name)).to eql(
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

          expect(bit_set.to_i).to eql 6
        end
      end

      describe "#[]" do
        it "should return true if the digit given by symbol is on" do
          bit_set = BitSet.new(0b100, traffic_light_configuration)

          expect(bit_set[:red]).to eq true
        end

        it "should return true if the digit given by index is on" do
          bit_set = BitSet.new(0b100, traffic_light_configuration)

          expect(bit_set[0]).to eq true
        end

        it "should return false if the digit given by symbol is off" do
          bit_set = BitSet.new(0b11101, generic_configuration)

          expect(bit_set[:d]).to eq false
        end

        it "should return false if the digit given by index is off" do
          bit_set = BitSet.new(0b11101, generic_configuration)

          expect(bit_set[3]).to eq false
        end
      end

      describe "#enabled_digits" do
        it "should return the set of digits which are on" do
          bit_set = BitSet.new(0b10101, generic_configuration)

          expect(bit_set.enabled_digits).to eql Set[:a, :c, :e]
        end
      end

      describe "#disabled_digits" do
        it "should return the set of digits which are off" do
          bit_set = BitSet.new(0b001, traffic_light_configuration)

          expect(bit_set.disabled_digits).to eql Set[:red, :yellow]
        end
      end

      describe "#invert" do
        it "should return a copy with every digit on/off state toggled" do
          bit_set = BitSet.new(0b101, traffic_light_configuration)

          result = bit_set.invert
          expect(result).to be_a(BitSet)
          expect(result.configuration).to eql traffic_light_configuration
          expect(result.to_i).to eql 0b010
          expect(result).not_to equal bit_set
        end
      end

      describe "#+" do
        it "should return a copy with all added digits switched to on (given a BitSet)" do
          bit_set = BitSet.new(0b01000, generic_configuration)

          result = bit_set + BitSet.new([:a, :d], generic_configuration)

          expect(result).to be_a(BitSet)
          expect(result.configuration).to eql generic_configuration
          expect(result.to_i).to eql 0b11010
          expect(result).not_to equal bit_set
        end

        it "should return a copy with all added digits switched to on (given an Enumerable)" do
          bit_set = BitSet.new(0b01010, generic_configuration)

          result = bit_set + Set[:a, :d]

          expect(result).to be_a(BitSet)
          expect(result.configuration).to eql generic_configuration
          expect(result.to_i).to eql 0b11010
          expect(result).not_to equal bit_set
        end
      end

      describe "#-" do
        it "should return a copy with all added digits switched to on (given a BitSet)" do
          bit_set = BitSet.new(0b110, traffic_light_configuration)

          result = bit_set - BitSet.new([:yellow, :green], traffic_light_configuration)

          expect(result).to be_a(BitSet)
          expect(result.configuration).to eql traffic_light_configuration
          expect(result.to_i).to eql 0b100
          expect(result).not_to equal bit_set
        end

        it "should return a copy with all added digits switched to on (given an Enumerable)" do
          bit_set = BitSet.new(0b101, traffic_light_configuration)

          result = bit_set - [:red, :yellow]

          expect(result).to be_a(BitSet)
          expect(result.configuration).to eql traffic_light_configuration
          expect(result.to_i).to eql 0b001
          expect(result).not_to equal bit_set
        end
      end

      [:union, :|].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with all enabled digits of both operands switched to on (given a BitSet)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:d, :e], generic_configuration))

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql generic_configuration
            expect(result.to_i).to eql 0b01111
            expect(result).not_to equal bit_set
          end

          it "should return a copy with all enabled digits of both operands switched to on (given an Integer)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name, 0b00011)

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql generic_configuration
            expect(result.to_i).to eql 0b01111
            expect(result).not_to equal bit_set
          end
        end
      end

      [:intersection, :&].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with only those digits switched to on which are on in both operands (given a BitSet)" do
            bit_set = BitSet.new(0b110, traffic_light_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:yellow, :green], traffic_light_configuration))

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql traffic_light_configuration
            expect(result.to_i).to eql 0b010
            expect(result).not_to equal bit_set
          end

          it "should return a copy with only those digits switched to on which are on in both operands (given an Integer)" do
            bit_set = BitSet.new(0b110, traffic_light_configuration)

            result = bit_set.public_send(method_name, 0b011)

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql traffic_light_configuration
            expect(result.to_i).to eql 0b010
            expect(result).not_to equal bit_set
          end
        end
      end

      [:symmetric_difference, :^].each do |method_name|
        describe "##{method_name}" do
          it "should return a copy with only those digits switched to on which are uniquely enabled in both operands (given a BitSet)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name,
                       BitSet.new([:d, :e], generic_configuration))

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql generic_configuration
            expect(result.to_i).to eql 0b01110
            expect(result).not_to equal bit_set
          end

          it "should return a copy with only those digits switched to on which are uniquely enabled in both operands (given an Integer)" do
            bit_set = BitSet.new(0b01101, generic_configuration)

            result = bit_set.public_send(method_name, 0b00011)

            expect(result).to be_a(BitSet)
            expect(result.configuration).to eql generic_configuration
            expect(result.to_i).to eql 0b01110
            expect(result).not_to equal bit_set
          end
        end
      end

      describe "#==" do
        let(:bit_set) { BitSet.new(0b110, traffic_light_configuration) }

        it "should return true if state and configuration is equal" do
          expect(bit_set).to eq(BitSet.new(0b110, traffic_light_configuration))
        end

        it "should return true if state and configuration is equal (different class)" do
          expect(bit_set).to eq(OpenStruct.new(integer_representation: 0b110, configuration: traffic_light_configuration))
        end

        it "should return false if state is equal but configuration differs" do
          expect(bit_set).not_to eq(BitSet.new(0b110, generic_configuration))
        end

        it "should return false if configuration is equal but state differs" do
          expect(bit_set).not_to eq(BitSet.new(0b010, traffic_light_configuration))
        end

        it "should return false if both state and configuration differ" do
          expect(bit_set).not_to eq(BitSet.new(0b010, generic_configuration))
        end

        it "should return false if compared to incompatible type" do
          expect(bit_set).not_to eq(:incompatible)
        end
      end

      describe "#eql?" do
        let(:bit_set) { BitSet.new(0b110, traffic_light_configuration) }

        it "should return true if state and configuration is equal" do
          expect(bit_set).to eql BitSet.new(0b110, traffic_light_configuration)
        end

        it "should return false if state and configuration is equal (different class)" do
          expect(bit_set).not_to eql OpenStruct.new(integer_representation: 0b110, configuration: traffic_light_configuration)
        end

        it "should return false if state is equal but configuration differs" do
          expect(bit_set).not_to eql BitSet.new(0b110, generic_configuration)
        end

        it "should return false if configuration is equal but state differs" do
          expect(bit_set).not_to eql BitSet.new(0b010, traffic_light_configuration)
        end

        it "should return false if both state and configuration differ" do
          expect(bit_set).not_to eql BitSet.new(0b010, generic_configuration)
        end

        it "should return false if compared to an incompatible object" do
          expect(bit_set).not_to eql :incompatible
        end
      end

      describe "#<=>" do
        let(:bit_set) { BitSet.new(11, generic_configuration) }

        it "should return -1 if state is lower than that of the compared" do
          expect(bit_set <=> BitSet.new(12, generic_configuration)).to eql -1
        end

        it "should return 0 if state is equal to that of the compared" do
          expect(bit_set <=> BitSet.new(11, generic_configuration)).to eql 0
        end

        it "should return 1 if state is higher than that of the compared" do
          expect(bit_set <=> BitSet.new(10, generic_configuration)).to eql 1
        end

        it "should return nil if configuration differs" do
          expect(bit_set <=> BitSet.new(11, traffic_light_configuration)).to be_nil
        end

        it "should return nil if compared to an incompatible object" do
          expect(bit_set <=> :incompatible).to be_nil
        end

        it "should make BitSet sortable" do
          result = [BitSet.new(11, generic_configuration),
                    BitSet.new(10, generic_configuration),
                    BitSet.new(12, generic_configuration)].sort

          expect(result).to eql [
            BitSet.new(10, generic_configuration),
            BitSet.new(11, generic_configuration),
            BitSet.new(12, generic_configuration)
          ]
        end
      end

      describe "#hash" do
        let(:bit_set) { BitSet.new(0b01011, generic_configuration) }

        it "should be stable over multiple calls" do
          expect(bit_set.hash).to eql bit_set.hash
        end

        it "should differ if state is equal but configuration differs" do
          expect(bit_set.hash).not_to eql BitSet.new(0b01011, traffic_light_configuration).hash
        end

        it "should differ if configuration is equal but state differs" do
          expect(bit_set.hash).not_to eql BitSet.new(0b00010, generic_configuration).hash
        end

        it "should differ if both state and configuration differ" do
          expect(bit_set.hash).not_to eql BitSet.new(0b00010, traffic_light_configuration).hash
        end
      end

      describe "#inspect" do
        it "should return a decent string representation for debugging" do
          result = BitSet.new(0b011, traffic_light_configuration).inspect

          expect(result).to eql '#<GodObject::BitSet::BitSet: "-yg">'
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

            expect(result).to eql "00101"
          end

          it "should display every digit as either it's assigned character or a dash if digits have assigned characters" do
            result = BitSet.new(0b101, traffic_light_configuration).to_s

            expect(result).to eql "r-g"
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

            expect(result).to eql "ry"
          end

          it "should diplay one dash when no digit is on" do
            result = BitSet.new(0, traffic_light_configuration).to_s(:short)

            expect(result).to eql "-"
          end
        end
      end

    end
  end
end
