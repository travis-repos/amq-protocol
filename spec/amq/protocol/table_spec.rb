# encoding: binary

require File.expand_path('../../../spec_helper', __FILE__)
require 'bigdecimal'


module AMQ
  module Protocol
    describe Table do
      timestamp    = Time.utc(2010, 12, 31, 23, 58, 59)
      bigdecimal_1 = BigDecimal.new("1.0")
      bigdecimal_2 = BigDecimal.new("5E-3")
      bigdecimal_3 = BigDecimal.new("-0.01")


      DATA = if one_point_eight?
        {
          {}                       => "\000\000\000\000",
          {"test" => 1}            => "\000\000\000\n\004testI\000\000\000\001",
          {"float" => 1.87}        => "\000\000\000\017\005floatd\354Q\270\036\205\353\375?",
          {"test" => "string"}     => "\000\000\000\020\004testS\000\000\000\006string",
          {"test" => {}}           => "\000\000\000\n\004testF\000\000\000\000",
          {"test" => bigdecimal_1} => "\000\000\000\v\004testD\000\000\000\000\001",
          {"test" => bigdecimal_2} => "\000\000\000\v\004testD\003\000\000\000\005",
          {"test" => timestamp}    => "\000\000\000\016\004testT\000\000\000\000M\036nC"
        }
      else
        {
          {}                       => "\x00\x00\x00\x00",
          {"test" => 1}            => "\x00\x00\x00\n\x04testI\x00\x00\x00\x01",
          {"float" => 1.92}        => "\x00\x00\x00\x0F\x05floatd\xB8\x1E\x85\xEBQ\xB8\xFE?",
          {"test" => "string"}     => "\x00\x00\x00\x10\x04testS\x00\x00\x00\x06string",
          {"test" => {}}           => "\x00\x00\x00\n\x04testF\x00\x00\x00\x00",
          {"test" => bigdecimal_1} => "\x00\x00\x00\v\x04testD\x00\x00\x00\x00\x01",
          {"test" => bigdecimal_2} => "\x00\x00\x00\v\x04testD\x03\x00\x00\x00\x05",
          {"test" => timestamp}    => "\x00\x00\x00\x0e\x04testT\x00\x00\x00\x00M\x1enC"
        }
      end

      describe ".encode" do
        it "should return \"\x00\x00\x00\x00\" for nil" do
          encoded_value = if one_point_eight?
                            "\000\000\000\000"
                          else
                            "\x00\x00\x00\x00"
                          end

          Table.encode(nil).should eql(encoded_value)
        end

        it "should return \"\x00\x00\x00\n\x04testI\x00\x00\x00\x01\" for { :test => true }" do
          Table.encode(:test => true).should eql("\x00\x00\x00\n\x04testI\x00\x00\x00\x01")
        end

        it "should return \"\x00\x00\x00\n\x04testI\x00\x00\x00\x01\" for { :coordinates => { :latitude  => 59.35, :longitude => 18.066667 } }" do
          Table.encode(:coordinates => { :latitude  => 59.35, :longitude => 18.066667 }).should eql("\000\000\0006\vcoordinatesF\000\000\000%\blatituded\315\314\314\314\314\254M@\tlongituded\361\270\250\026\021\0212@")
        end

        DATA.each do |data, encoded|
          it "should return #{encoded.inspect} for #{data.inspect}" do
            Table.encode(data).should eql(encoded)
          end
        end
      end

      describe ".decode" do
        DATA.each do |data, encoded|
          it "should return #{data.inspect} for #{encoded.inspect}" do
            Table.decode(encoded).should eql(data)
          end

          it "is capable of decoding what it encodes" do
            Table.decode(Table.encode(data)).should == data
          end
        end
      end
    end
  end
end
