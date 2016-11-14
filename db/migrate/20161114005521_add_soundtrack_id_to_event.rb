class AddSoundtrackIdToEvent < ActiveRecord::Migration
  def up
    add_column    :events, :soundtrack_id, :integer
  end

  def down
    remove_column :events, :soundtrack_id, :integer
  end
end
