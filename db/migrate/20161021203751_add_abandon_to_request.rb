class AddAbandonToRequest < ActiveRecord::Migration
  def up
    add_column :song_requests, :is_abandoned, :boolean, null: false, default: false
  end

  def down
    remove_column :song_requests, :is_abandoned, :boolean
  end
end
