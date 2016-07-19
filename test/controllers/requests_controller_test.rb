require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def setup
    @band      = bands(:h4h)
    @event     = events(:brs8)
    @request   = requests(:one)
    @admin     = users(:michael)
    @nonadmin  = users(:malory)
    @member    = users(:ray)
    @nonmember = users(:donnie)
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
    post :create, request: {
      song:     "The Test Song",
      artist:   "Doesn't Matter",
      band_id:  @band.id,
      event_id: @event.id
    }
    assert_redirected_to events_url
  end

  test "members can create a song request" do
    log_in_as @member
    assert_difference 'Request.count', 1, 'Creating a request adds one.' do
      post :create, request: {
        song:     "The Test Song",
        artist:   "Doesn't Matter",
        band_id:  @band.id,
        event_id: @event.id
      }
    end
    assert_redirected_to event_url(@event.id)
  end

  test "guests cannot mark a song request as complete" do
    patch :toggle_completed, id: @request
    assert_redirected_to login_url
    @request.reload
    assert !@request.is_completed
  end

  test "nonadmins cannot mark a song request as complete" do
    log_in_as @nonadmin
    patch :toggle_completed, id: @request
    assert_redirected_to root_url
    @request.reload
    assert !@request.is_completed
  end

  test "admins mark a song request as complete" do
    log_in_as @admin
    patch :toggle_completed, id: @request
    assert_redirected_to event_url(@event.id)
    @request.reload
    assert @request.is_completed
  end
end
