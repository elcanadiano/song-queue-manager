require 'test_helper'

class SoundtrackTest < ActiveSupport::TestCase
  def setup
  end

  test "is valid" do
    s = Soundtrack.new(name: "The Cat's Picks")
    assert s.valid?
  end

  test "nameless soundtracks are not valid" do
    s = Soundtrack.new
    assert !s.valid?
  end

  test "duplicate names are not valid" do
    s = Soundtrack.new(name: "Songs previously performed in Battle Rock Seattle")
    assert !s.valid?
  end

  test "duplicate names are not valid even in alternate case" do
    s = Soundtrack.new(name: "sONGS pREViously PERFORMED in BATTLE rOCK SEATTLE")
    assert !s.valid?
  end
end
