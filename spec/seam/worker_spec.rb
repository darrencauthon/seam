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

  describe "a more realistic example" do

    let(:flow) do
      flow = Seam::Flow.new
      flow.wait_for_attempting_contact_stage
      flow.determine_if_postcard_should_be_sent
      flow.send_postcard_if_necessary
      flow
    end

    let(:effort_creator) do
      ->() do
        e = flow.start
        Seam::Effort.find(e.id)
      end
    end
    
    let(:wait_for_attempting_contact_stage_worker) do
      worker = Seam::Worker.new
      worker.for(:wait_for_attempting_contact_stage)

      def worker.process
        @current_effort.data['hit 1'] ||= 0
        @current_effort.data['hit 1'] += 1
        move_to_next_step
      end

      worker
    end

    let(:determine_if_postcard_should_be_sent_worker) do
      worker = Seam::Worker.new
      worker.for(:determine_if_postcard_should_be_sent)

      def worker.process
        @current_effort.data['hit 2'] ||= 0
        @current_effort.data['hit 2'] += 1
        move_to_next_step
      end

      worker
    end

    let(:send_postcard_if_necessary_worker) do
      worker = Seam::Worker.new
      worker.for(:send_postcard_if_necessary)

      def worker.process
        @current_effort.data['hit 3'] ||= 0
        @current_effort.data['hit 3'] += 1
        move_to_next_step
      end

      worker
    end

    before do
      Timecop.freeze Time.parse('1/6/2013')
    end

    it "should progress through the story" do

      # SETUP
      effort = effort_creator.call
      effort.next_step.must_equal "wait_for_attempting_contact_stage"

      # FIRST WAVE
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all

      effort = Seam::Effort.find effort.id
      effort.next_step.must_equal "determine_if_postcard_should_be_sent"

      # SECOND WAVE
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all

      effort = Seam::Effort.find effort.id
      effort.next_step.must_equal "send_postcard_if_necessary"

      # THIRD WAVE
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all

      effort = Seam::Effort.find effort.id
      effort.next_step.must_equal nil

      effort.data['hit 1'].must_equal 1
      effort.data['hit 2'].must_equal 1
      effort.data['hit 3'].must_equal 1
      
      # FUTURE WAVES
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all
      send_postcard_if_necessary_worker.execute_all
      determine_if_postcard_should_be_sent_worker.execute_all
      wait_for_attempting_contact_stage_worker.execute_all

      effort = Seam::Effort.find effort.id
      effort.next_step.must_equal nil

      effort.data['hit 1'].must_equal 1
      effort.data['hit 2'].must_equal 1
      effort.data['hit 3'].must_equal 1

    end
  end
end
