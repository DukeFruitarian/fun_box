require "spec_helper"

module PictureGrabber
  describe Base do
    let(:params) do
      {:par1 => 0..10, :par2 => 10..20}
    end

    id=-1
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



    describe "#initialize" do
      context "without params" do
        it "set formats to default" do
          Base.new.formats.should be_eql(["jpg","png","jpeg","gif"])
        end
      end

      context "with correct params" do
        it "set formats when params is array" do
          Base.new(['jpg','jpeg']).formats.should be_eql(['jpg','jpeg'])
        end

        it "set formats when params are strings" do
          Base.new('jpg','jpeg').formats.should be_eql(['jpg','jpeg'])
        end
      end

      context "with incorrect params" do
        it "raise ArgumentError when params is an array contain not only strings" do
          lambda{
            Base.new(['jpg',1])
          }.should raise_error(ArgumentError)
        end

        it "raise ArgumentError when params are not only strings" do
          lambda{
            Base.new('jpg',1)
          }.should raise_error(ArgumentError)
        end
      end
    end

    describe "#grab" do
      let(:grabber) {Base.new("jpeg","jpg")}

      context "with correct params" do

      end

      context "with wrong params" do
        it "raise ArgumentError when URL not a string" do
          lambda{
            grabber.grab ["http://google.com"], "google"
          }.should raise_error(ArgumentError, "wrong URL")
        end

        it "raise ArgumentError when directory not a string" do
          lambda{
            grabber.grab "http://google.com", 1
          }.should raise_error(ArgumentError, "wrong name of subdirectory")
        end
      end
    end
  end
end
