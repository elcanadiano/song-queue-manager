require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    @admin      = users(:alexander)
    @other_user = users(:archer)
    @rebar      = events(:rebar)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @rebar
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @rebar, event: { name: "Name", date: Date.new(2015, 06, 02) }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect new when logged in as non-admin" do
    log_in_as(@other_user)
    get :new
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect edit when logged in as non-admin" do
    log_in_as(@other_user)
    get :edit, id: @rebar
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as non-admin" do
    log_in_as(@other_user)
    patch :update, id: @rebar, event: { name: "Name", date: Date.new(2015, 06, 02) }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should get new when logged in as admin" do
    log_in_as(@admin)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "should get edit when logged in as admin" do
    log_in_as(@admin)
    get :edit, id: @rebar
    assert flash.empty?
    assert_response :success
  end

  test "guests should not be able to toggle an event opening" do
    patch :toggle_open, id: @rebar
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "non-admins should not be able to toggle an event opening" do
    log_in_as(@other_user)
    patch :toggle_open, id: @rebar
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "admins should not be able to toggle an event opening" do
    log_in_as(@admin)
    patch :toggle_open, id: @rebar
    @rebar.reload
    assert @rebar.is_open
    assert_not flash.empty?
    assert_redirected_to events_url
  end
end
