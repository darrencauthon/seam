require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class AbcWorker < Seam::Worker

  attr_accessor :called

  def process
    @called ||= 0
    @called = @called + 1
  end
end

describe "calling a step twice in a row" do

  before do
    Seam::Persistence.destroy
  end

  it "should work" do
    flow = Seam::Flow.new
    flow.abc
    flow.abc

    effort = flow.start

    worker = AbcWorker.new
    worker.execute_all
    worker.execute_all
    worker.execute_all

    worker.called.must_equal 2
  end

end

