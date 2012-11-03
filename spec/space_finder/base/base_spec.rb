require "spec_helper"

module SpaceFinder
  describe Base do

    let(:arr) {[1,2,3,5,6,7,8,9,11,12,13]}
    let(:res) {[4,10]}

    it "find correct missed values" do
      Base.new(arr).spaces.should be_eql(res)
    end

    it "return nil on array without spaces" do
      Base.new([1,2,3,4,5,6,7,8,9]).spaces.should be_equal(nil)
    end

    describe "#initialize" do
      it "create new object of Base class" do
        Base.new(arr).should be_kind_of(Base)
      end
    end

    describe "#spaces" do
      it "caches results" do
        finder = Base.new(arr)
        result = finder.spaces
        result.should be_eql(res)
        finder.spaces.should be_equal(result)
      end
    end
  end
end
