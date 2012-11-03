require "spec_helper"

module SpaceFinder
  describe Base do
    before :each do
      @array = [1,2,3,5,6,7,8,9,11,12,13]
      @result = [4,10]
    end

    it "find correct missed values" do
      Base.new(@array).spaces.should be_eql(@result)
    end

    it "return nil on array without spaces" do
      full_array = [1,2,3,4,5,6,7,8,9]
      Base.new(full_array).spaces.should be_equal(nil)
    end

    describe "#initialize" do
      it "create new object of Base class" do
        Base.new(@array).should be_kind_of(Base)
      end
    end

    describe "#spaces" do
      it "caches results" do
        finder = Base.new(@array)
        res = finder.spaces
        res.should be_eql(@result)
        finder.spaces.should be_equal(res)
      end
    end
  end
end
