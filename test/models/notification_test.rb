require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def setup
    @invitee    = users(:chris)
    @member     = users(:erin)
    @noninvitee = users(:donnie)
    @reject     = users(:lana)
    @band       = bands(:h4h)
  end

  test "noninvitee can receive notification" do
    n = Notification.new(user_id: @noninvitee.id, band_id: @band.id)
    assert n.valid?
  end

  test "noninvitee cannot receive notification" do
    n = Notification.new(user_id: @invitee.id, band_id: @band.id)
    assert_not n.valid?
  end

  test "reject can receive notification" do
    n = Notification.new(user_id: @reject.id, band_id: @band.id)
    assert n.valid?
  end

  test "member cannot receive notification" do
    n = Notification.new(user_id: @member.id, band_id: @band.id)
    assert_not n.valid?
  end
end
