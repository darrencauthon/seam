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
      effort = Seam::Effort.find(effort.id)

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

      e = flow.start( { first_name: 'John' } )
      Seam::Effort.find(e.id)
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

  describe "more copmlex example" do

    let(:effort1) do
      flow = Seam::Flow.new
      flow.grape
      flow.mango

      e = flow.start( { status: 'Good' } )
      Seam::Effort.find(e.id)
    end
    
    let(:effort2) do
      flow = Seam::Flow.new
      flow.grape
      flow.mango

      e = flow.start( { status: 'Bad' } )
      Seam::Effort.find(e.id)
    end

    before do
      Timecop.freeze Time.parse('1/6/2013')

      apple_worker = Seam::Worker.new
      apple_worker.for(:apple)
      def apple_worker.process
        if @current_effort.data['status'] == 'Good'
          move_to_next_step
        else
          try_again_in 1.day
        end
      end

      apple_worker.execute effort1
      apple_worker.execute effort2
    end

    it "should move the first effort forward" do
      fresh_effort = Seam::Effort.find(effort1.id)
      fresh_effort.next_step.must_equal "mango"
    end

    it "should keep the second effort at the same step" do
      fresh_effort = Seam::Effort.find(effort2.id)
      fresh_effort.next_step.must_equal "grape"
      fresh_effort.next_execute_at.must_equal Time.parse('2/6/2013')
    end
  end

  describe "processing all pending steps for one effort" do
    let(:effort1_creator) do
      ->() do
        flow = Seam::Flow.new
        flow.banana
        flow.mango

        e = flow.start
        Seam::Effort.find(e.id)
      end
    end
    
    let(:effort2_creator) do
      ->() do
        flow = Seam::Flow.new
        flow.apple
        flow.orange

        e = flow.start
        Seam::Effort.find(e.id)
      end
    end

    let(:apple_worker) do
      apple_worker = Seam::Worker.new
      apple_worker.for(:apple)

      apple_worker.class_eval do
        attr_accessor :count
      end

      def apple_worker.process
        self.count += 1
      end

      apple_worker.count = 0
      apple_worker
    end

    before do
      Timecop.freeze Time.parse('1/6/2013')

      effort1_creator.call
      effort1_creator.call
      effort1_creator.call
      effort2_creator.call
      effort2_creator.call

      apple_worker.execute_all
    end

    it "should call the apple worker for the record in question" do
      apple_worker.count.must_equal 2
    end
  end
end
