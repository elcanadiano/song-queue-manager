class RenameOrderToSongOrder < ActiveRecord::Migration
  def up
    rename_column :song_requests, :order,      :song_order
    add_column    :events,        :song_order, :integer,   null: false, default: 0
  end

  def down
    remove_column :events,        :song_order
    rename_column :song_requests, :song_order, :order
  end
end
