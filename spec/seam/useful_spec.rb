require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class UsefulExample < Seam::Flow
end

describe "a useful example" do
  let(:flow) do
    f = Seam::Flow.new
    f.wait_for_attempting_contact_stage
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
  end
end
