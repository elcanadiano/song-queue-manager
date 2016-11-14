require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @soundtrack = soundtracks(:brspast)
  end

  test "should not be valid without soundtrack" do
    e = Event.new(name: "Test Rock Band Event", date: Date.new(2017, 5, 1))
    assert !e.valid?
  end

  test "should be valid with soundtrack" do
    e = Event.new(name: "Test Rock Band Event", date: Date.new(2017, 5, 1), soundtrack: @soundtrack)
    assert e.valid?
  end
end
