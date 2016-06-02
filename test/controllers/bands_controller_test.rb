require 'test_helper'

class BandsControllerTest < ActionController::TestCase
  def setup
    @non_member = users(:lana)
    @member     = users(:erin)
    @admin      = users(:alexander)
    @invited    = users(:chris)
    @band       = bands(:h4h)
  end

  test "guests cannot see band info" do
    get :show, id: @band.id
    assert_redirected_to login_url
  end

  test "non-members can see band info" do
    log_in_as(@non_member)
    get :show, id: @band.id
    assert_response :success
  end

  test "members can see band info" do
    log_in_as(@member)
    get :show, id: @band.id
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should see new when logged in" do
    log_in_as(@member)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @band
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not admin" do
    log_in_as(@member)
    get :edit, id: @band
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should not update if not logged in" do
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should not update if not admin" do
    log_in_as(@member)
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should update if admin" do
    log_in_as(@admin)
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_not flash.empty?
    assert_redirected_to bands_user_url(@admin)
  end

  test "should redirect invite when not logged in" do
    get :invite, id: @band
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect invite when not admin" do
    log_in_as(@member)
    get :invite, id: @band
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "send invite" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id}
    assert_not flash.empty?
    assert_redirected_to band_url(@band)
  end

  test "incorrect creator does not send invite" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @member.id}
    assert_not flash.empty?
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user does not exist" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: -99999, creator_id: @admin.id}
    assert_not flash.empty?
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user is already invited" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @invited.id, creator_id: @admin.id}
    assert_not flash.empty?
    assert_redirected_to invite_band_url
  end

  test "invite not sent to current member" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @member.id, creator_id: @admin.id}
    assert_not flash.empty?
    assert_redirected_to invite_band_url
  end
end
