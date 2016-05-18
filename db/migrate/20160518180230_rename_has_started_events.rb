class RenameHasStartedEvents < ActiveRecord::Migration
  def up
    # Rename the has_started flag to is_open to better reflect its usage for
    # allowing requests to come in or not.
    remove_index  :events, [:has_started, :date,   :is_completed]
    rename_column :events,  :has_started, :is_open
    add_index     :events, [:is_open,     :date,   :is_completed]
  end

  def down
    remove_index  :events, [:is_open,     :date,       :is_completed]
    rename_column :events,  :is_open,     :has_started
    add_index     :events, [:has_started, :date,       :is_completed]
  end
end
