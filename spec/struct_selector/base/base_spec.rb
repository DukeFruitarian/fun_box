require "spec_helper"

module StructSelector
  describe Base do
    let(:params) do
      {:par1 => 0..10, :par2 => 10..20}
    end

    id=-1
    let(:collection) do
      id = -1
      (0..99).to_a.map do
        id = id + 1
        obj = stub('object',
          params.keys.first => (id%10 != 0 ?
            rand(params[params.keys.first].last) :
            params[params.keys.first].last),
          params.keys.last => rand(params[params.keys.last].count),
          :id => id).as_null_object
      end
    end

    before :each do
      @params = {:par1 => 0..10, :par2 => 10..20}
      id=-1
      @collection = (0..99).to_a.map do
        id = id + 1
        obj = stub('object',
          @params.keys.first => (id%10 != 0 ?
            rand(@params[@params.keys.first].last) :
            @params[@params.keys.first].last),
          @params.keys.last => rand(@params[@params.keys.last].count),
          :id => id).as_null_object
      end
    end

    let(:selector) {Base.new(collection,params)}

    describe "#initialize" do
      after :each do
        Base.new(@collection,@params)
      end

      it "create hash of object's attribute-values" do
        @collection.each do |obj|
          @params.each_pair do |attribute,range|
            obj.should_receive(attribute)
          end
        end
      end

      context "collection respond to set_selector" do
        it "send set_selector to the collection" do
          @collection.should_receive(:respond_to?).with(:set_selector).and_return(true)
          @collection.should_receive(:set_selector)
        end
      end

      context "collection not respond to set_selector" do
        it "don't 'send set_selector to the collection" do
          @collection.should_receive(:respond_to?).with(:set_selector).and_return(false)
          @collection.should_not_receive(:set_selector)
        end
      end
    end

    describe "#select" do
      before :each do
        @selector = Base.new(@collection,@params)
      end

      it "return nil if params not a hash" do
        @selector.select(123).should be_nil
        @selector.select(nil).should be_nil
      end

      it "return full collection if params an empty hash" do
        @selector.select({}).to_a.should be_eql(@collection)
      end

      it "cache the results of search" do
        res = @selector.select(params.keys.first => 5)
        @selector.select(params.keys.first => 5).to_a.should be_equal(res)
      end
    end

    describe "methods" do
      before :each do
        @selector = Base.new(@collection,@params)
      end

      describe "#add_obj" do
        it "add value to data-hash" do
          obj = stub('object',
            @params.keys.first => 5,
            @params.keys.last => 5,
            :id => 10001).as_null_object
          @params.each_pair do |attribute,range|
            obj.should_receive(attribute)
          end
          @selector.add_obj(obj)
        end

        it "include new object to be selected" do
          obj = stub('object',
            @params.keys.first => 2,
            @params.keys.last => 5,
            :id => 100).as_null_object
          @collection << obj
          @selector.select(params.keys.first => 2).should_not include(obj)
          @selector.empty_cache!
          @selector.add_obj(obj)
          @selector.select(params.keys.first => 2).should include(obj)
        end
      end

      describe "#del_obj" do
        it "object deleted from cache and can't be selected" do
          obj = @collection[10]
          @selector.select(params.keys.first => obj.send(params.keys.first)).should include(obj)
          @selector.del_obj(obj)
          @selector.select(params.keys.first => obj.send(params.keys.first)).should_not include(obj)
        end
      end

      it "select objects correspond to query" do
        result = (0..99).step(10).map{|id| @collection[id]}
        @selector.select(@params.keys.first =>
          @params[params.keys.first].last).should be_eql(result.to_a)
      end
    end
  end # describe Base
end # module StructSelector
