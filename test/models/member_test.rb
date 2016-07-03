require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  def setup
    @dankey = users(:dankey)
    @tribe  = bands(:dankey)
    @lana   = users(:lana)
  end

  test "should be valid" do
    m = Member.new(user_id: @lana.id, band_id: @tribe.id)
    assert m.valid?
  end

  test "there should not be a duplicate member" do
    m = Member.new(user_id: @dankey.id, band_id: @tribe.id)
    assert_not m.valid?
  end
end
