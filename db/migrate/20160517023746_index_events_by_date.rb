class IndexEventsByDate < ActiveRecord::Migration
  def change
      add_index :events, [:has_started, :date, :is_completed]
  end
end
