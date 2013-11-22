require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seam::WaitWorker do

  it "should be a worker" do
    Seam::WaitWorker.new.is_a? Seam::Worker
  end

  it "should handle the wait step" do
    Seam::WaitWorker.new.step.must_equal 'wait'
  end
end
