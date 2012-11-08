require "spec_helper"

class Cars < StructSelector::Collections::Redis
end

module StructSelector
  module Collections
    describe Redis do
      describe "#initialize" do
        it "create new redis client without params" do
          ::Redis.should_receive(:new).with({})
          Cars.new
        end

        it "create new redis client with params" do
          params = {:port => 1234, :host => "192.168.0.15"}
          ::Redis.should_receive(:new).with(params)
          Cars.new params
        end
      end

      describe "methods" do
        before :each do
          @collection = Cars.new
        end

        describe "#set_selector" do

          it "setting selector from params" do
            selector = stub('selector')
            @collection.set_selector(selector)
            @collection.instance_eval("@selector").should be_equal(selector)
          end
        end

        describe "#add" do
          before :each do
            @car = mock('Cars', :id => 15)
          end

          it "add obj to redis" do
            @collection.instance_eval("@redis").should_receive(:hset).with("cars", @car.id.to_s,Marshal.dump(@car))
            @collection.add @car
          end

          it "call selector#add_obj" do
            selector = mock('selector')
            @collection.set_selector selector
            selector.should_receive(:add_obj).with(@car)
            @collection.add @car
          end
        end

        describe "#each" do
          xit "" do
          end
        end
      end
    end
  end
end
