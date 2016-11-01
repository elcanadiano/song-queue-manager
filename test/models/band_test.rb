require 'test_helper'

class BandTest < ActiveSupport::TestCase
  def setup
    @new_band   = Band.new(name: "The Band of Doom")
    @band       = bands(:h4h)
    @member     = users(:erin)
    @non_member = users(:lana)
  end

  test "should be valid" do
    assert @new_band.valid?
  end

  test "band names should be unique" do
    @new_band.name = "Harmonies for Hire"
    assert !@new_band.valid?
  end

  test "is a member of the band" do
    assert @band.is_member?(@member.id)
  end

  test "is not a member of the band" do
    assert !@band.is_member?(@non_member.id)
  end
end
