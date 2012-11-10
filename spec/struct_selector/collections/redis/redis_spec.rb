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
          @redis = @collection.instance_eval("@redis")
          @car = mock('Cars', :id => 15)
        end

        describe "#set_selector" do

          it "setting selector from params" do
            selector = stub('selector')
            @collection.set_selector(selector)
            @collection.instance_eval("@selector").should be_equal(selector)
          end
        end

        describe "#add" do
          it "add obj to redis" do
            @redis.should_receive(:hset).with("cars", @car.id.to_s,Marshal.dump(@car))
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
          it "takes all objects from DB" do
            cars = (0..50).map do |id|
              car = mock('car', :id => id)
              Marshal.should_receive(:load).with(Marshal.dump(car)).and_return(car)
              car.should_receive(:type)
              Marshal.dump(car)
            end
            @redis.should_receive(:hvals).with("cars").and_return(cars)
            @collection.map{|car| car.type}.should have(51).cars
          end
        end

        describe "#[]"do
          context "with exist id" do
            it "return object with given id" do
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(Marshal.dump(@car))
              Marshal.should_receive(:load).with(Marshal.dump(@car)).and_return(@car)
              @collection[@car.id].should be_equal(@car)
            end
          end

          context "with not exist id" do
            it "return nil" do
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(nil)
              Marshal.should_not_receive(:load)
              @collection[@car.id].should be_equal(nil)
            end
          end
        end

        describe "#del_by_id!" do
          before :each do
            @selector = mock('selector')
          end

          it "delete object from redis database" do
            @redis.should_receive(:hdel).with("cars", @car.id.to_s)
            @collection.del_by_id! @car.id
          end

          context "with exist id in database and setuped selector" do
            it "send #del_obj with obj to selector" do
              @selector.should_receive(:del_obj).with(@car)
              @collection.set_selector @selector
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(Marshal.dump(@car))
              Marshal.should_receive(:load).with(Marshal.dump(@car)).and_return(@car)
              @collection.del_by_id! @car.id
            end

            it "return deleted object" do
              @selector.should_receive(:del_obj).with(@car).and_return(@car)
              @collection.set_selector @selector
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(Marshal.dump(@car))
              Marshal.should_receive(:load).with(Marshal.dump(@car)).and_return(@car)
              @collection.del_by_id!(@car.id).should be_equal(@car)
            end
          end

          context "without id in database" do
            it "not send to selector" do
              @selector.should_not_receive(:del_obj)
              @collection.set_selector @selector
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(nil)
              Marshal.should_not_receive(:load)
              @collection.del_by_id! @car.id
            end

            it "return nil" do
              @collection.set_selector @selector
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(nil)
              @collection.del_by_id!(@car.id).should be_equal(nil)
            end
          end

          context "without setuped selector" do
            it "not send to selector" do
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(Marshal.dump(@car))
              @collection.instance_eval("@selector").should_not_receive(:del_obj)
              Marshal.should_not_receive(:load)
              @collection.del_by_id! @car.id
            end

            it "return nil" do
              @redis.should_receive(:hget).with("cars", @car.id.to_s).and_return(Marshal.dump(@car))
              @collection.del_by_id!(@car.id).should be_equal(nil)
            end
          end
        end

        describe "#del!" do
          it "send object's id from param to #del_by_id!" do
            @collection.should_receive(:del_by_id!).with(@car.id)
            @collection.del!(@car)
          end
        end
      end
    end
  end
end
