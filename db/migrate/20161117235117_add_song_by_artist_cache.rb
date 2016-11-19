class AddSongByArtistCache < ActiveRecord::Migration
  def up
    add_column    :songs, :song_by_artist, :string
  end

  def down
    remove_column :songs, :song_by_artist
  end
end
