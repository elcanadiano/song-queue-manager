require 'test_helper'

class EventsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:alexander)
    @event      = events(:rebar)
    @soundtrack = soundtracks(:brspast)
  end

  test "successful edit with friendly forwarding" do
    get edit_event_path(@event)
    log_in_as(@user)
    assert_redirected_to edit_event_path(@event)
    name  = "Battle Rock Seattle at the Re-bar"
    patch event_path(@event), event: {name: name, soundtrack: @soundtrack.id}
    assert_equal "Event Updated!", flash[:success]
    assert_redirected_to events_path
    @event.reload
    assert_equal name,  @event.name
  end
end
