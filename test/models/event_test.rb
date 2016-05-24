require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @event = Event.new(name: "Test Rock Band Event", date: Date.new(2017, 5, 1))
  end

  test "should be valid" do
    assert @event.valid?
  end
end
