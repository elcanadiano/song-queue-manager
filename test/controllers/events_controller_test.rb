require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    @user       = users(:alexander)
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
    log_in_as(@user)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "should get edit when logged in as admin" do
    log_in_as(@user)
    get :edit, id: @rebar
    assert flash.empty?
    assert_response :success
  end

end
