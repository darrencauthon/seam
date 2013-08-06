require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "worker" do

  before do
    test_moped_session['efforts'].drop
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
end
