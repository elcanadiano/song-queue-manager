require 'test_helper'

class BandsControllerTest < ActionController::TestCase
  def setup
    @non_member = users(:lana)
    @member     = users(:erin)
    @admin      = users(:alexander)
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
end
