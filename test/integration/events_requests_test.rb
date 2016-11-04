require 'test_helper'

class EventsRequestsTest < ActionDispatch::IntegrationTest

  def setup
    @event                         = events(:brs8)
    @event_with_no_completed_songs = events(:brs7)
    @admin                         = users(:alexander)
  end

  # Tests for the song count sidebar of brs8 according to the fixture data.
  # The count should be as follows, with the ordering being the song count
  # (descending) followed by the band name (ascending).
  #
  # Dankey Kang and the Tribe - 3
  # Harmonies for Hire        - 3
  # No Boston After Midnight  - 2
  test "song requests count for ongoing event with completed songs" do
    log_in_as(@admin)
    get event_path(@event)
    assert_template 'events/show'

    # Assert the table exists.
    assert_select "#song-request-count > tbody > tr", 3

    # Dankey is first.
    assert_select "#song-request-count > tbody > tr:nth-child(1) > td:nth-child(1)", "Dankey Kang and the Tribe"
    assert_select "#song-request-count > tbody > tr:nth-child(1) > td:nth-child(2)", "3"

    # H4H is second.
    assert_select "#song-request-count > tbody > tr:nth-child(2) > td:nth-child(1)", "Harmonies for Hire"
    assert_select "#song-request-count > tbody > tr:nth-child(2) > td:nth-child(2)", "3"

    # NBAM is last.
    assert_select "#song-request-count > tbody > tr:nth-child(3) > td:nth-child(1)", "No Boston After Midnight"
    assert_select "#song-request-count > tbody > tr:nth-child(3) > td:nth-child(2)", "2"
  end

  # BRS7 has no completed song requests, so there should not be a requests
  # table. Instead we get a message saying, "There have been no completed
  # songs."
  test "no song requests count for ongoing event without completed songs" do
    log_in_as(@admin)
    get event_path(@event_with_no_completed_songs)
    assert_template 'events/show'

    # Assert the table does not exist.
    assert_select "#song-request-count", false, "The Song Request Table should not exist."

    # Assert that request-sidebar contains the message.
    assert_select "#request-sidebar", "There have been no completed songs."
  end
end
