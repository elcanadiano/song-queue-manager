class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
      t.references :user
      t.references :creator
      t.references :band, index: true, foreign_key: true
      t.boolean :has_expired, default: false

      t.timestamps null: false
    end
  end
end
