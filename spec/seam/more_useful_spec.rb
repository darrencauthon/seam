require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "a more useful example" do

  before do
    test_moped_session['efforts'].drop
  end

  describe "starting an effort" do
    let(:flow) do
      flow = Seam::Flow.new
      flow.do_something
      flow.do_something_else
      flow
    end

    let(:now) { Time.parse('1/1/2011') }

    before do
      Timecop.freeze now

      @expected_uuid = SecureRandom.uuid.to_s
      SecureRandom.expects(:uuid).returns @expected_uuid

      @effort = flow.start( { first_name: 'John' } )
    end

    after do
      Timecop.return
    end

    it "should mark no steps as completed" do
      @effort.completed_steps.count.must_equal 0
    end

    it "should stamp the effort with a uuid" do
      @effort.id.must_equal @expected_uuid
    end

    it "should stamp the create date" do
      @effort.created_at.must_equal now
    end

    it "should stamp the next execute date" do
      @effort.next_execute_at.must_equal now
    end

    it "should stamp the next step name" do
      @effort.next_step.must_equal "do_something"
    end

    it "should save an effort in the db" do
      effort = Seam::Effort.find @effort.id
      effort.to_hash.contrast_with! @effort.to_hash
    end
  end
end
