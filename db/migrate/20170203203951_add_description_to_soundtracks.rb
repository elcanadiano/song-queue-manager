class AddDescriptionToSoundtracks < ActiveRecord::Migration
  def up
    add_column    :soundtracks, :description, :text
  end

  def down
    remove_column :soundtracks, :description
  end
end
