require 'test_helper'

class BandsInvitationTest < ActionDispatch::IntegrationTest

  def setup
    @admin            = users(:alexander)
    @admin_membership = members(:alexander)
    @non_member       = users(:lana)
    @band             = bands(:h4h)
  end

  test "invite member to band" do
    # Log in as the admin and send an invite to the non-member.
    get invite_band_path(@band)
    log_in_as(@admin)
    assert_redirected_to invite_band_path(@band)
    post create_invite_band_path(@band.id), notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id}
    # Log out.
    delete logout_path
    assert_redirected_to root_url
    # Log in as the non-member and accept the invitation.
    log_in_as(@non_member)
    assert !@band.is_member?(@non_member.id)
    get notifications_path
    lana_notification = Notification.find_by(band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id, has_expired: false)
    patch accept_notification_path(lana_notification.id)
    @band.reload
    assert @band.is_member?(@non_member.id)
  end

  test "decline invite member to band" do
    # Log in as the admin and send an invite to the non-member.
    get invite_band_path(@band)
    log_in_as(@admin)
    assert_redirected_to invite_band_path(@band)
    post create_invite_band_path(@band.id), notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id}
    # Log out.
    delete logout_path
    assert_redirected_to root_url
    # Log in as the non-member and decline the invitation.
    log_in_as(@non_member)
    assert !@band.is_member?(@non_member.id)
    get notifications_path
    lana_notification = Notification.find_by(band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id, has_expired: false)
    patch decline_notification_path(lana_notification.id)
    @band.reload
    assert !@band.is_member?(@non_member.id)
  end
end
