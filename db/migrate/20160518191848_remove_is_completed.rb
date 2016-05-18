class RemoveIsCompleted < ActiveRecord::Migration
  def up
    # Remove the is_completed flag as it is not needed.
    remove_index  :events, [:is_open,     :date, :is_completed]
    remove_column :events,  :is_completed
    add_index     :events, [:is_open,     :date]
  end

  def down
    remove_index  :events, [:is_open,     :date]
    add_column    :events,  :is_completed
    add_index     :events, [:is_open,     :date, :is_completed]
  end
end
