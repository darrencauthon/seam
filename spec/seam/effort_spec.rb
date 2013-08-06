require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seam::Effort do
  before do
    test_moped_session['efforts'].drop
  end

  let(:flow) do
    f = Seam::Flow.new
    f.step1
    f.step2
    f
  end

  describe "updating an effort" do
    it "should not create another document in the collection" do
      effort = flow.start
      test_moped_session['efforts'].find.count.must_equal 1
      effort.save
      test_moped_session['efforts'].find.count.must_equal 1

      second_effort = flow.start
      test_moped_session['efforts'].find.count.must_equal 2
      second_effort.save
      test_moped_session['efforts'].find.count.must_equal 2
    end
  end
end
