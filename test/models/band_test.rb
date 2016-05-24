require 'test_helper'

class BandTest < ActiveSupport::TestCase
  def setup
    @band = Band.new(name: "The Band of Doom")
  end

  test "should be valid" do
    assert @band.valid?
  end

  test "band names should be unique" do
    @band.name = "Harmonies for Hire"
    assert !@band.valid?
  end
end
