class CreateSoundtracks < ActiveRecord::Migration
  def up
    create_table :soundtracks do |t|
      t.string :name

      t.timestamps null: false
    end
  end

  def down
    drop_table :soundtracks
  end
end
