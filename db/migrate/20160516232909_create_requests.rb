class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :song
      t.string :artist
      t.integer :order
      t.boolean :is_completed
      t.references :event, index: true, foreign_key: true
      t.references :band, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :requests, :order
  end
end
