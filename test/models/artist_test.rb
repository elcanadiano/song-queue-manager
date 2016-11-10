require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  def setup
  end

  test "is valid" do
    a = Artist.new(name: "The Rutles")
    assert a.valid?
  end

  test "nameless artists are not valid" do
    a = Artist.new
    assert !a.valid?
  end

  test "duplicate names are not valid" do
    a = Artist.new(name: "The Beatles")
    assert !a.valid?
  end
end
