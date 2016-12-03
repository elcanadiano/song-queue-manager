require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    @admin         = users(:alexander)
    @other_user    = users(:archer)
    @bandless_user = users(:bandless)
    @rebar         = events(:rebar)
    @closed_event  = events(:brs7)
    @soundtrack    = soundtracks(:brspast)
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

  test "should redirect new when logged in as non-admin" do
    log_in_as(@other_user)
    get :new
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should get new when logged in as admin" do
    log_in_as(@admin)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "should redirect new when there are no soundtracks" do
    log_in_as(@admin)
    assert !Soundtrack.all.blank?
    Soundtrack.delete_all
    assert Soundtrack.all.blank?
    get :new
    assert_equal "You cannot create an event unless you have a soundtrack.", flash[:warning]
    assert_redirected_to soundtracks_url
  end

  test "should not create when not logged in" do
    assert_no_difference 'Event.count', 'An event should be created if you are not logged in.' do
      post :create, event: {
        name: "Name",
        date: Date.new(2015, 06, 02),
        soundtrack: @soundtrack.id
      }
    end

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should not create when logged in as non-admin" do
    log_in_as(@other_user)

    assert_no_difference 'Event.count', 'An event should be created if you are not logged in.' do
      post :create, event: {
        name: "Name",
        date: Date.new(2015, 06, 02),
        soundtrack: @soundtrack.id
      }
    end

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should not create without soundtrack" do
    log_in_as(@admin)

    assert_no_difference 'Event.count', 'An event should be created if you are not logged in.' do
      post :create, event: {
        name: "Name",
        date: Date.new(2015, 06, 02)
      }
    end

    assert_template 'new'
  end

  test "should create when logged in as admin" do
    log_in_as(@admin)

    assert_difference 'Event.count', 1, 'Creating an event adds one.' do
      post :create, event: {
        name: "Name",
        date: Date.new(2015, 06, 02),
        soundtrack: @soundtrack.id
      }
    end

    assert_equal "Event created successfully!", flash[:success]
    assert_redirected_to events_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @rebar
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as non-admin" do
    log_in_as(@other_user)
    get :edit, id: @rebar
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should get edit when logged in as admin" do
    log_in_as(@admin)
    get :edit, id: @rebar
    assert flash.empty?
    assert_response :success
  end

  test "should redirect update when not logged in" do
    patch :update, id: @rebar, event: {name: "Name", date: Date.new(2015, 06, 02), soundtrack: @soundtrack.id}

    # Ensure that the fields did not change.
    @rebar.reload
    assert_equal "ReBar - January 2016", @rebar.name
    assert_equal Date.new(2016, 01, 04), @rebar.date

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect update when logged in as non-admin" do
    log_in_as(@other_user)
    patch :update, id: @rebar, event: {name: "Name", date: Date.new(2015, 06, 02), soundtrack: @soundtrack.id}

    # Ensure that the fields did not change.
    @rebar.reload
    assert_equal "ReBar - January 2016", @rebar.name
    assert_equal Date.new(2016, 01, 04), @rebar.date

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should not update without a soundtrack when admin" do
    log_in_as(@admin)
    patch :update, id: @rebar, event: {name: "Name", date: Date.new(2015, 06, 02)}

    # Ensure that the fields did not change.
    @rebar.reload
    assert_equal "ReBar - January 2016", @rebar.name
    assert_equal Date.new(2016, 01, 04), @rebar.date

    assert_template 'edit'
  end

  test "should update when logged in as admin" do
    log_in_as(@admin)
    patch :update, id: @rebar, event: {name: "Name", date: Date.new(2015, 06, 02), soundtrack: @soundtrack.id}

    # Ensure that the fields did change.
    @rebar.reload
    assert_equal "Name",                 @rebar.name
    assert_equal Date.new(2015, 06, 02), @rebar.date

    assert_equal "Event Updated!", flash[:success]
    assert_redirected_to events_url
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

  test "bandless users should redirect to bands user page" do
    log_in_as(@bandless_user)
    get :song_request, id: @rebar
    assert_equal "You must create or be part of a band in order to make a request.", flash[:warning]
    assert_redirected_to event_url(@rebar)
  end

  test "members should not be able to visit song request page of closed event" do
    log_in_as(@other_user)
    get :song_request, id: @closed_event
    assert_equal "We're sorry, but this event is not open for requests.", flash[:danger]
    assert_redirected_to events_url
  end

  test "members should be able to visit song request page of open event" do
    log_in_as(@other_user)
    get :song_request, id: @rebar

    # Archer, the "other user", should be part of one band. Therefore, there
    # should be two options, the second being "Select Band".
    assert_select "#song_request_band_id > option", 2

    assert flash.empty?
    assert_response :success
  end

  test "admins should be able to visit song request page of open event" do
    log_in_as(@admin)
    get :song_request, id: @rebar

    # An admin should have the ability to create a song request for any band.
    # Therefore, there should be one option for each band, plus one more for
    # "Select Band", and an additional one for "".
    assert_select "#song_request_band_id > option", Band.count + 2

    assert flash.empty?
    assert_response :success
  end
end
