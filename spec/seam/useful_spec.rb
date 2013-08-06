require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class UsefulExample < Seam::Flow
end

describe "a useful example" do
  let(:flow) do
    f = Seam::Flow.new
    f.wait_for_attempting_contact_stage limit: 2.weeks
    f.determine_if_postcard_should_be_sent
    f.branch_on(:postcard_should_be_sent, {
                                            'yes' => :send_the_postcard,
                                          })
    f
  end

  describe "steps that must be taken" do
    before do
      flow
    end

    it "should not throw an error" do
      flow.steps.count.must_equal 3
    end

    it "should set the name of the three steps" do
      flow.steps[0].name.must_equal "wait_for_attempting_contact_stage"
      flow.steps[1].name.must_equal "determine_if_postcard_should_be_sent"
      flow.steps[2].name.must_equal "branch_on_postcard_should_be_sent"
    end

    it "should set the step types of the three steps" do
      flow.steps[0].type.must_equal "do"
      flow.steps[1].type.must_equal "do"
      flow.steps[2].type.must_equal "branch"
    end
  end
end
