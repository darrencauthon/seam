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
      first_effort = flow.start
      test_moped_session['efforts'].find.count.must_equal 1
      first_effort.save
      test_moped_session['efforts'].find.count.must_equal 1

      second_effort = flow.start
      test_moped_session['efforts'].find.count.must_equal 2
      second_effort.save
      test_moped_session['efforts'].find.count.must_equal 2
    end

    it "should update the information" do
      first_effort = flow.start
      second_effort = flow.start

      first_effort.next_step = 'i_changed_the_first_one'
      first_effort.save
      first_effort.to_hash.contrast_with! Seam::Effort.find(first_effort.id).to_hash
      second_effort.to_hash.contrast_with! Seam::Effort.find(second_effort.id).to_hash

      second_effort.next_step = 'i_changed_the_second_one'
      second_effort.save
      first_effort.to_hash.contrast_with! Seam::Effort.find(first_effort.id).to_hash
      second_effort.to_hash.contrast_with! Seam::Effort.find(second_effort.id).to_hash
    end
  end
end
