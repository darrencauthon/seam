require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seam::Flow do
  describe "empty" do
    let(:flow) { Seam::Flow.new }

    it "should have an empty set of steps" do
      flow.steps.count.must_equal 0
    end
  end

  describe "one action setup" do
    let(:flow) do
                 flow = Seam::Flow.new
                 flow.do_something
                 flow
               end

    it "should return one step" do
      flow.steps.count.must_equal 1
    end

    it "should return a DoStep" do
      flow.steps.first.is_a?(Seam::DoStep).must_equal true
    end

    it "should contain the name of the step" do
      flow.steps.first.name.must_equal "do_something"
    end
  end
end
