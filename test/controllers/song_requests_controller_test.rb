require 'test_helper'

class SongRequestsControllerTest < ActionController::TestCase
  def setup
    @band         = bands(:h4h)
    @closed_event = events(:brs7)
    @open_event   = events(:brs8)
    @song_request = song_requests(:one)
    @two          = song_requests(:two)
    @three        = song_requests(:three)
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

  test "admins can create a song request on behalf of a band" do
    log_in_as @admin

    assert !Member.exists?(user_id: @admin, band_id: @band)

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

  test "nonmembers cannot create a song request on behalf of a band" do
    log_in_as @nonmember

    assert !Member.exists?(user_id: @nonmember, band_id: @band)

    assert_no_difference 'SongRequest.count', 'A nonmember should not be able to create a request on behalf of another band.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    assert "This user is not a member of the band.", flash[:danger]
    assert_redirected_to events_url
  end

  test "admins can create a song request on behalf of a new band" do
    new_band_name = "The New Band Name"
    log_in_as @admin

    assert_difference ['SongRequest.count', 'Band.count'], 1, 'Creating a request adds a request and a band.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  0,
        event_id: @open_event.id
      }, new_band: new_band_name
    end

    assert Band.exists?(name: new_band_name)

    assert_equal "Song added successfully!", flash[:success]
    assert_redirected_to event_url(@open_event.id)
  end

  test "admins cannot create a song request on behalf of a new band without a name" do
    new_band_name = ""
    log_in_as @admin

    assert_no_difference ['SongRequest.count', 'Band.count'], 'An empty band name will not create a new band.' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  0,
        event_id: @open_event.id
      }, new_band: new_band_name
    end

    assert flash.empty?
    assert_template "events/song_request"
  end

  test "non-admins cannot create a song request on behalf of a new band" do
    new_band_name = "The New Band Name"
    log_in_as @member

    assert_no_difference ['SongRequest.count', 'Band.count'], 'Non-admins cannot create requests on behalf of new bands' do
      post :create, song_request: {
        song:     @song.id,
        band_id:  0,
        event_id: @open_event.id
      }, new_band: new_band_name
    end

    assert !Band.exists?(name: new_band_name)

    assert "This user is not a member of the band.", flash[:danger]
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
    assert @song_request.request?
    patch :toggle_completed, id: @song_request

    assert_redirected_to login_url
    @song_request.reload
    assert_equal "Please log in.", flash[:danger]
    assert @song_request.request?
  end

  test "nonadmins cannot mark a song request as complete" do
    assert @song_request.request?
    log_in_as @nonadmin
    patch :toggle_completed, id: @song_request

    assert_redirected_to root_url
    @song_request.reload
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert @song_request.request?
  end

  test "admins mark a song request as complete" do
    assert @song_request.request?
    log_in_as @admin
    patch :toggle_completed, id: @song_request
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload

    last_song_position = Event.find(@song_request.event_id).song_order - 1
    assert_equal last_song_position, @song_request.song_order

    assert_equal "Song Completed!", flash[:success]
    assert @song_request.completed?
  end

  test "admins cannot mark an abandoned song request as complete" do
    assert @abandoned.abandoned?
    log_in_as @admin
    patch :toggle_completed, id: @abandoned
    assert_redirected_to event_url(@open_event.id)
    @abandoned.reload
    assert_equal "The song is already abandoned.", flash[:danger]
    assert !@abandoned.completed?
  end

  test "guests cannot mark a song request as abandoned" do
    assert @song_request.request?
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to login_url
    @song_request.reload
    assert_equal "Please log in.", flash[:danger]
    assert @song_request.request?
  end

  test "nonadmins cannot mark a song request as abandoned" do
    assert @song_request.request?, "Song should be in request status to start."
    log_in_as @nonadmin
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to root_url
    @song_request.reload
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert @song_request.request?
  end

  test "admins mark a song request as abandoned" do
    assert @song_request.request?, "Song should be in request status to start."
    log_in_as @admin
    patch :toggle_abandoned, id: @song_request
    assert_redirected_to event_url(@open_event.id)
    @song_request.reload

    last_song_position = Event.find(@song_request.event_id).song_order - 1
    assert_equal last_song_position, @song_request.song_order

    assert_equal "Song Abandoned!", flash[:success]
    assert @song_request.abandoned?, "Song should be abandoned."
  end

  test "admins cannot mark a completed song request as abandoned" do
    assert @completed.completed?, "Song should have a status of completed to start."
    log_in_as @admin
    patch :toggle_abandoned, id: @completed

    assert_redirected_to event_url(@open_event.id)
    @song_request.reload
    assert_equal "The song is already completed.", flash[:danger]
    assert !@completed.abandoned?, "Song should not be abandoned."
  end

  test "guests cannot move song request by AJAX" do
    patch :reorder, xhr: true, format: :json, request_id: @song_request.id, new_index: @three.song_order

    @song_request.reload
    @two.reload
    @three.reload

    assert_equal @song_request.song_order, 0
    assert_equal @two.song_order,          1
    assert_equal @three.song_order,        2

    assert_response 401
  end

  test "non-admins cannot move song request by AJAX" do
    log_in_as @nonadmin
    patch :reorder, xhr: true, format: :json, request_id: @song_request.id, new_index: @three.song_order

    @song_request.reload
    @two.reload
    @three.reload

    assert_equal @song_request.song_order, 0
    assert_equal @two.song_order,          1
    assert_equal @three.song_order,        2

    assert_response 403
  end

  test "moving down song request by AJAX" do
    log_in_as @admin
    patch :reorder, xhr: true, format: :json, request_id: @song_request.id, new_index: @three.song_order

    @song_request.reload
    @two.reload
    @three.reload

    assert_equal @song_request.song_order, 2
    assert_equal @two.song_order,          0
    assert_equal @three.song_order,        1

    assert_response :success
  end

  test "moving up song request by AJAX" do
    log_in_as @admin
    patch :reorder, xhr: true, format: :json, request_id: @three.id, new_index: @song_request.song_order

    @song_request.reload
    @two.reload
    @three.reload

    assert_equal @song_request.song_order, 1
    assert_equal @two.song_order,          2
    assert_equal @three.song_order,        0

    assert_response :success
  end
end
