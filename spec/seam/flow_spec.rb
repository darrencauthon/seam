require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seam::Flow do
  describe "empty" do
    let(:flow) { Seam::Flow.new }

    it "should have an empty set of steps" do
      flow.steps.count.must_equal 0
    end

    it "should provide the mechanism for serializing itself" do
      string = flow.serialize
      new_flow = Seam::Flow.deserialize string
      new_flow.class.must_equal Seam::Flow
      new_flow.seams.count.must_equal 1
    end
  end

  [:name].to_objects {[
    ['do_something'],
    ['something_else']
  ]}.each do |test|
    describe "one action setup" do
      let(:flow) do
                   flow = Seam::Flow.new
                   flow.send(test.name)
                   flow
                 end

      it "should return one step" do
        flow.steps.count.must_equal 1
      end

      it "should return a DoStep" do
        flow.steps.first.is_a?(Seam::DoStep).must_equal true
      end

      it "should contain the name of the step" do
        flow.steps.first.name.must_equal test.name
      end
    end
  end
end
