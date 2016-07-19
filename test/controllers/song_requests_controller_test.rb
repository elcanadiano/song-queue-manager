require 'test_helper'

class SongRequestsControllerTest < ActionController::TestCase
  def setup
    @band           = bands(:h4h)
    @event          = events(:brs8)
    @song_request   = song_requests(:one)
    @admin          = users(:michael)
    @nonadmin       = users(:malory)
    @member         = users(:ray)
    @nonmember      = users(:donnie)
  end

  test "guests cannot create a song request" do
    post :create, request: {
      song:     "The Test Song",
      artist:   "Doesn't Matter",
      band_id:  @band.id,
      event_id: @event.id
    }
    assert_redirected_to login_url
  end

  test "non-members cannot create a song request" do
    log_in_as @nonmember

    post :create, song_request: {
      song:     "The Test Song",
      artist:   "Doesn't Matter",
      band_id:  @band.id,
      event_id: @event.id
    }
    assert_redirected_to events_url
  end

  test "members can create a song request" do
    log_in_as @member

    assert_difference 'SongRequest.count', 1, 'Creating a request adds one.' do
      post :create, song_request: {
        song:     "The Test Song",
        artist:   "Doesn't Matter",
        band_id:  @band.id,
        event_id: @event.id
      }
    end
    assert_redirected_to event_url(@event.id)
  end

  test "guests cannot mark a song request as complete" do
    patch :toggle_completed, id: @song_request
    assert_redirected_to login_url
    @song_request.reload
    assert !@song_request.is_completed
  end

  test "nonadmins cannot mark a song request as complete" do
    log_in_as @nonadmin
    patch :toggle_completed, id: @song_request
    assert_redirected_to root_url
    @song_request.reload
    assert !@song_request.is_completed
  end

  test "admins mark a song request as complete" do
    log_in_as @admin
    patch :toggle_completed, id: @song_request
    assert_redirected_to event_url(@event.id)
    @song_request.reload
    assert @song_request.is_completed
  end
end
