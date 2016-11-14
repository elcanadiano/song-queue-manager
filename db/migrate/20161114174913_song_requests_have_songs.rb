class SongRequestsHaveSongs < ActiveRecord::Migration
  def up
    add_column    :song_requests, :song_id, :integer
    remove_column :song_requests, :artist
    remove_column :song_requests, :song
  end

  def down
    add_column    :song_requests, :artist, :string
    add_column    :song_requests, :song,   :string
    remove_column :song_requests, :song_id
  end
end
