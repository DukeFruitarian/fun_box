require "spec_helper"

module StructSelector
  describe Base do

    id=-1

    let(:params) do
      {:par1 => 0..10, :par2 => 10..20}
    end

    let(:collection) do

      (0..100).to_a.map do
        id = id + 1
        obj = stub('object',
          params.keys.first => (id%10 != 0 ?
            rand(params[params.keys.first].last) :
            params[params.keys.first].last),
          params.keys.last => rand(params[params.keys.last].count),
          :id => id).as_null_object
      end
    end

    let(:selector) {Base.new(collection,params)}

    describe "#initialize" do
      it "create hash of object's attribute-values" do
        collection.each do |obj|
          params.each_pair do |attribute,range|
            obj.should_receive(attribute)
          end
        end
        Base.new(collection,params)
      end
    end

    it "select objects correspond to query" do
      result = (0..100).step(10).map{|id| collection[id]}
      selector.select(params.keys.first =>
        params[params.keys.first].last).should be_eql(result.to_a)
    end

    describe "#select" do
      it "return nil if params not a hash" do
        selector.select(123).should be_nil
        selector.select(nil).should be_nil
      end

      it "return full collection if params an empty hash" do
        selector.select({}).to_a.should be_eql(collection)
      end

      it "cache the results of search" do
        res = selector.select(params.keys.first => 5)
        selector.select(params.keys.first => 5).to_a.should be_equal(res)
      end
    end
  end
end
