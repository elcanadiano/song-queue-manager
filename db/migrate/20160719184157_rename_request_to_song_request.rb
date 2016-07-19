class RenameRequestToSongRequest < ActiveRecord::Migration
  def up
    rename_table :requests,     :song_requests
  end

  def down
    rename_table :song_requests, :requests
  end
end
