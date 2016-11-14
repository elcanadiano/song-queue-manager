require 'test_helper'

class SongRequestsControllerTest < ActionController::TestCase
  def setup
    @band         = bands(:h4h)
    @closed_event = events(:brs7)
    @open_event   = events(:brs8)
    @song_request = song_requests(:one)
    @completed    = song_requests(:completed)
    @abandoned    = song_requests(:abandoned)
    @song         = songs(:pretender)
    @admin        = users(:michael)
    @nonadmin     = users(:malory)
    @member       = users(:ray)
    @nonmember    = users(:donnie)
  end

  test "guests cannot create a song request" do
    assert_no_difference 'SongRequest.count', 'There should be no request added.' do
      post :create, request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-members cannot create a song request" do
    log_in_as @nonmember

    assert_no_difference 'SongRequest.count', 'There should be no request added.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    assert_equal "This user is not a member of the band.", flash[:danger]
    assert_redirected_to events_url
  end

  test "song requests need songs" do
    log_in_as @member

    assert_no_difference 'SongRequest.count', 'There should be no request added.' do
      post :create, song_request: {
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    assert_template 'events/song_request'
  end

  test "members can create a song request" do
    log_in_as @member

    assert_difference 'SongRequest.count', 1, 'Creating a request adds one.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    assert_equal "Song added successfully!", flash[:success]
    assert_redirected_to event_url(@open_event.id)
  end

  test "cannot create a song request when event is closed" do
    log_in_as @member

    assert_no_difference 'SongRequest.count', 'There should be no request added.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @closed_event.id
      }
    end

    assert_equal "We're sorry, but this event is not open for requests.", flash[:danger]
    assert_redirected_to events_url
  end

  test "guests cannot mark a song request as complete" do
    patch :toggle_completed, id: @song_request
    assert_redirected_to login_url
    @song_request.reload
    assert_equal "Please log in.", flash[:danger]
    assert !@song_request.is_completed
  end

  test "nonadmins cannot mark a song request as complete" do
    log_in_as @nonadmin
    patch :toggle_completed, id: @song_request
    assert_redirected_to root_url
    @song_request.reload
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert !@song_request.is_completed
  end

  test "admins mark a song request as complete" do
    log_in_as @admin
    patch :toggle_completed, id: @song_request
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload
    assert_equal "Song Completed!", flash[:success]
    assert @song_request.is_completed
  end

  test "admins cannot mark an abandoned song request as complete" do
    log_in_as @admin
    patch :toggle_completed, id: @abandoned
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload
    assert_equal "The song is already abandoned.", flash[:danger]
    assert !@song_request.is_completed
  end

  test "guests cannot mark a song request as abandoned" do
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to login_url
    @song_request.reload
    assert_equal "Please log in.", flash[:danger]
    assert !@song_request.is_abandoned
  end

  test "nonadmins cannot mark a song request as abandoned" do
    log_in_as @nonadmin
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to root_url
    @song_request.reload
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert !@song_request.is_abandoned
  end

  test "admins mark a song request as abandoned" do
    log_in_as @admin
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload
    assert_equal "Song Abandoned!", flash[:success]
    assert @song_request.is_abandoned
  end

  test "admins cannot mark an completed song request as abandoned" do
    log_in_as @admin
    patch :toggle_abandoned, id: @completed
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload
    assert_equal "The song is already completed.", flash[:danger]
    assert !@song_request.is_abandoned
  end
end
