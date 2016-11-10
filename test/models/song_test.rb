require 'test_helper'

class SongTest < ActiveSupport::TestCase
  def setup
    @artist     = artists(:elo)
    @duplicate1 = artists(:greenday)
    @duplicate2 = artists(:beegees)
    @duplicate3 = artists(:madonna)
  end

  test "needs an artist to be valid" do
    s = Song.new(name: "Rockaria!")
    assert !s.valid?
  end

  test "has an artist and is valid" do
    s = Song.new(name: "Rockaria!")
    s.artists << @artist
    assert s.valid?
  end

  test "nameless songs are not valid" do
    s = Song.new
    s.artists << @artist
    assert !s.valid?
  end

  # The fixture data contains both Holiday by Green Day and Holiday by the
  # Bee Gees. Here we will create a song called "Holiday" by Madonna, which is
  # valid.
  test "duplicate song titles with different artists is valid" do
    s = Song.new(name: "Holiday")
    s.artists << @duplicate3
    assert s.valid?
  end

  # There is no enforcement on a duplicate song, same artist.
  test "duplicate song titles with same artists is valid" do
    s = Song.new(name: "Holiday")
    s.artists << @duplicate2
    assert s.valid?
  end

  # There is no enforcement on a duplicate song, same artist.
  test "songs with multiple artists is valid" do
    s = Song.new(name: "Super Holiday")
    s.artists += [@duplicate2, @duplicate1, @duplicate3]
    assert s.valid?
  end
end
