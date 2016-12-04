require 'test_helper'

class SongRequestsTest < ActionDispatch::IntegrationTest

  def setup
    @user_admin = users(:michael)
    @member     = users(:erin)
    @non_member = users(:malory)
    @band       = bands(:h4h)
    @open_event = events(:brs8)
    @song       = songs(:pretender)
  end

  test "creating a song request" do
    # Testing Login
    get request_event_url(@open_event)
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url

    # Login as a non-member. Because Malory is not part of any bands, she will
    # be redirected out.
    log_in_as @non_member
    get request_event_url(@open_event)
    assert_equal "You must create or be part of a band in order to make a request.", flash[:warning]
    delete logout_path

    # Login and visit the request page.
    log_in_as @member
    assert is_logged_in?
    assert_not flash.empty?
    get request_event_url(@open_event)
    assert_template 'events/song_request'

    # Create a request.
    assert_difference 'SongRequest.count', 1, 'Creating a request adds one.' do
      post requests_url, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end
  end

  test "admin creating a song request on behalf of a user" do
    # Testing Login
    get request_event_url(@open_event)
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url

    # Login and visit the request page.
    log_in_as @user_admin
    assert is_logged_in?
    assert_not flash.empty?
    get request_event_url(@open_event)
    assert_template 'events/song_request'

    # This admin is not a member.
    assert !Member.exists?(band_id: @band.id, user_id: @user_admin.id)

    # Create a request.
    assert_difference 'SongRequest.count', 1, 'Creating a request adds one.' do
      post requests_url, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end
  end

  test "admin creating a song request on behalf of a new band" do
    new_band_name = "The New Band Name"
    # Testing Login
    get request_event_url(@open_event)
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url

    # Login as a non-member. Erin can't do this request because she is not an
    # admin.
    log_in_as @member
    get request_event_url(@open_event)
    assert_template 'events/song_request'
    assert_no_difference ['SongRequest.count', 'Band.count'], 'Cannot create a request on behalf of a new band.' do
      post requests_url, song_request: {
        song:     @song.id,
        band_id:  0,
        event_id: @open_event.id
      }, new_band: new_band_name
    end
    assert_equal "This user is not a member of the band.", flash[:danger]
    assert_redirected_to events_url
    delete logout_path

    # Login as an admin and visit the request page.
    log_in_as @user_admin
    assert is_logged_in?
    assert_not flash.empty?
    get request_event_url(@open_event)
    assert_template 'events/song_request'

    # Create a request.
    assert_difference ['SongRequest.count', 'Band.count'], 1, 'Creating a request adds a request and a band.' do
      post requests_url, song_request: {
        song:     @song.id,
        band_id:  0,
        event_id: @open_event.id
      }, new_band: new_band_name
    end

    assert Band.exists?(name: new_band_name)

    assert_equal "Song added successfully!", flash[:success]
    assert_redirected_to event_url(@open_event.id)
  end
end
