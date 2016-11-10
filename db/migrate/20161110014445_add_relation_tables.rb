class AddRelationTables < ActiveRecord::Migration
  def up
    create_table :songs_soundtracks, id: false do |t|
      t.integer :song_id
      t.integer :soundtrack_id
    end

    add_index :songs_soundtracks, :song_id
    add_index :songs_soundtracks, :soundtrack_id

    create_table :artists_songs, id: false do |t|
      t.integer :song_id
      t.integer :artist_id
    end

    add_index :artists_songs, :song_id
    add_index :artists_songs, :artist_id
  end

  def down
    drop_table :songs_soundtracks
    drop_table :artists_songs
  end
end
