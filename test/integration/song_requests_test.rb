require 'test_helper'

class SongRequestsTest < ActionDispatch::IntegrationTest

  def setup
    @user_admin = users(:michael)
    @member     = users(:erin)
    @non_member = users(:malory)
    @band       = bands(:h4h)
    @open_event = events(:brs8)
    @song       = songs(:pretender)
    @song2      = songs(:iwantitall)
    @song3      = songs(:brainstew)
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

    # Create a request or two.
    assert_difference 'SongRequest.count', 3, 'Creating three requests add three.' do
      post requests_url, song_request: {
        song:     @song.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }

      post requests_url, song_request: {
        song:     @song2.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }

      post requests_url, song_request: {
        song:     @song3.id,
        band_id:  @band.id,
        event_id: @open_event.id
      }
    end

    # Get the three songs.
    song1 = SongRequest.find_by({
      song_id:  @song,
      band_id:  @band,
      event_id: @open_event
    })

    song2 = SongRequest.find_by({
      song_id:  @song2,
      band_id:  @band,
      event_id: @open_event
    })

    song3 = SongRequest.find_by({
      song_id:  @song3,
      band_id:  @band,
      event_id: @open_event
    })

    # Ensure they are all in "request" status.
    assert song1.request?
    assert song2.request?
    assert song3.request?

    # Login as a user admin.
    delete logout_path
    log_in_as @user_admin
    assert is_logged_in?

    # For song1, mark it as in progress then mark as completed.
    patch toggle_started_request_url(song1)
    song1.reload

    assert_equal "Song Started!", flash[:success]
    assert song1.in_progress?

    patch toggle_completed_request_url(song1)
    song1.reload

    assert_equal "Song Completed!", flash[:success]
    assert song1.completed?

    # For song2, mark it as in progress then mark as abandoned.
    patch toggle_started_request_url(song2)
    song2.reload

    assert_equal "Song Started!", flash[:success]
    assert song2.in_progress?

    patch toggle_abandoned_request_url(song2)
    song2.reload

    assert_equal "Song Abandoned!", flash[:success]
    assert song2.abandoned?

    # For song3, mark as completed (fail) then mark as abandoned.
    patch toggle_completed_request_url(song3)
    song3.reload

    assert_equal "The song needs to be in progress before it can be marked as completed.", flash[:danger]
    assert song3.request?

    patch toggle_abandoned_request_url(song3)
    song3.reload

    assert_equal "Song Abandoned!", flash[:success]
    assert song3.abandoned?
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
