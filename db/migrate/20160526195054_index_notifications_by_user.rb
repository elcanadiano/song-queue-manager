class IndexNotificationsByUser < ActiveRecord::Migration
  def up
      add_index :notifications, [:user_id]
  end

  def down
      remove_index :notifications, [:user_id]
  end
end
