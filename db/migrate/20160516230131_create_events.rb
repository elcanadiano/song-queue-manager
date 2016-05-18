class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.boolean :has_started
      t.boolean :is_completed

      t.timestamps null: false
    end
  end
end
