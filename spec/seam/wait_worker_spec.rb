require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seam::WaitWorker do

  it "should be a worker" do
    Seam::WaitWorker.new.is_a? Seam::Worker
  end

  it "should handle the wait step" do
    Seam::WaitWorker.new.step.must_equal 'wait'
  end

  describe "using it in a flow" do

    let(:flow) do
      f = Seam::Flow.new
      f.wait 3.days
      f.do_something
      f
    end

    let(:effort_id) do
      effort = flow.start
      effort.id
    end

    let(:today) do
      Time.parse '1/1/2011'
    end

    before do
      Timecop.freeze today
      effort_id
    end

    it "should immediately wait" do
      Seam::WaitWorker.new.execute_all
      Seam::Effort.find(effort_id).next_step.must_equal "wait"
    end

    it "should continue on after the days have passed" do
      Seam::WaitWorker.new.execute_all

      Timecop.freeze(today + 3.days + 1.second)

      Seam::WaitWorker.new.execute_all
      Seam::Effort.find(effort_id).next_step.must_equal "do_something"
    end

  end
end
