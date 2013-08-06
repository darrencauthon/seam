require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "a more useful example" do

  describe "starting an effort" do
    let(:flow) do
      flow = Seam::Flow.new
      flow.do_something
      flow.do_something_else
      flow
    end

    before do
      @expected_uuid = SecureRandom.uuid.to_s
      SecureRandom.expects(:uuid).returns @expected_uuid

      @effort = flow.start( { first_name: 'John' } )
    end

    it "should mark no steps as completed" do
      @effort.completed_steps.count.must_equal 0
    end

    it "should stamp the effort with a uuid" do
      @effort.id.must_equal @expected_uuid
    end
  end
end
