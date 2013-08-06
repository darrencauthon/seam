require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "worker" do

  before do
    test_moped_session['efforts'].drop
  end

  after do
    Timecop.return
  end

  describe "move_to_next_step" do
    it "should work" do
      flow = Seam::Flow.new
      flow.apple
      flow.orange

      effort = flow.start( { first_name: 'John' } )

      effort.next_step.must_equal "apple"

      apple_worker = Seam::Worker.new
      apple_worker.for(:apple)
      def apple_worker.process
        move_to_next_step
      end

      apple_worker.execute effort

      effort = Seam::Effort.find(effort.id)
      effort.next_step.must_equal "orange"
    end
  end

  describe "try_again_in" do

    let(:effort) do
      flow = Seam::Flow.new
      flow.apple
      flow.orange

      flow.start( { first_name: 'John' } )
    end

    before do
      Timecop.freeze Time.parse('3/4/2013')


      effort.next_step.must_equal "apple"

      apple_worker = Seam::Worker.new
      apple_worker.for(:apple)
      def apple_worker.process
        try_again_in 1.day
      end

      apple_worker.execute effort
    end

    it "should not update the next step" do
      fresh_effort = Seam::Effort.find(effort.id)
      fresh_effort.next_step.must_equal "apple"
    end

    it "should not update the next execute date" do
      fresh_effort = Seam::Effort.find(effort.id)
      fresh_effort.next_execute_at.must_equal Time.parse('4/4/2013')
    end
  end
end
