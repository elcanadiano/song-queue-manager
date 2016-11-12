class AddIndexToNames < ActiveRecord::Migration
  def up
    add_index :songs, :name
    add_index :artists, :name
    add_index :soundtracks, :name
  end

  def down
    remove_index :songs, :name
    remove_index :artists, :name
    remove_index :soundtracks, :name
  end
end
