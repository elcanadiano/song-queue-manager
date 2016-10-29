require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    @admin        = users(:alexander)
    @other_user   = users(:archer)
    @rebar        = events(:rebar)
    @closed_event = events(:brs7)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @rebar
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @rebar, event: { name: "Name", date: Date.new(2015, 06, 02) }
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect new when logged in as non-admin" do
    log_in_as(@other_user)
    get :new
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should redirect edit when logged in as non-admin" do
    log_in_as(@other_user)
    get :edit, id: @rebar
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as non-admin" do
    log_in_as(@other_user)
    patch :update, id: @rebar, event: { name: "Name", date: Date.new(2015, 06, 02) }
    assert_equal "This function requires administrator privileges.", flash[:danger]
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
    @rebar.reload
    assert @rebar.is_open
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins should not be able to toggle an event opening" do
    log_in_as(@other_user)
    patch :toggle_open, id: @rebar
    @rebar.reload
    assert @rebar.is_open
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "admins should be able to toggle an event closing" do
    log_in_as(@admin)
    assert @rebar.is_open
    patch :toggle_open, id: @rebar
    @rebar.reload
    assert !@rebar.is_open
    assert_equal "#{@rebar.name} is now closed for requests!", flash[:success]
    assert_redirected_to events_url
  end

  test "admins should be able to toggle an event opening" do
    log_in_as(@admin)
    assert !@closed_event.is_open
    patch :toggle_open, id: @closed_event
    @closed_event.reload
    assert @closed_event.is_open
    assert_equal "#{@closed_event.name} is now open for requests!", flash[:success]
    assert_redirected_to events_url
  end

  test "guests should not be able to visit song request page" do
    get :song_request, id: @rebar
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "members should be able to visit song request page" do
    log_in_as(@other_user)
    get :song_request, id: @rebar
    assert_response :success
  end

  test "members should not be able to visit song request page of closed event" do
    log_in_as(@other_user)
    get :song_request, id: @closed_event
    assert_redirected_to events_url
  end
end
