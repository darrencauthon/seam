require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class DoSomething < Seam::Worker
  def process
  end
end

describe Seam::WaitWorker do

  it "should be a worker" do
    Seam::WaitWorker.new.is_a? Seam::Worker
  end

  it "should handle the wait step" do
    Seam::WaitWorker.new.step.must_equal 'wait'
  end

  let(:today) do
    Time.parse '1/1/2011'
  end

  let(:effort_id) do
    effort = flow.start
    effort.id
  end

  describe "using it in a flow" do

    [:length_of_time].to_objects { [
      [3.days],
      [1.day],
      [30.minutes]
    ] }.each do |test|

      describe "a simple situation" do

        let(:flow) do
          f = Seam::Flow.new
          f.wait test.length_of_time
          f.do_something
          f
        end

        before do
          Timecop.freeze today
          effort_id
        end

        it "should move to the next step" do
          Seam::WaitWorker.new.execute_all
          Seam::Effort.find(effort_id).next_step.must_equal "do_something"
        end
        j
        it "should set the next execute date" do
          Seam::WaitWorker.new.execute_all
          Seam::Effort.find(effort_id).next_execute_at.must_equal (today + test.length_of_time)
        end

      end

    end
    
  end

end
