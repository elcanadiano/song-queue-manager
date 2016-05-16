class DropMicroposts < ActiveRecord::Migration
  def up
    drop_table :microposts
  end

  def down
    create_table "microposts", force: :cascade do |t|
      t.text     "content"
      t.integer  "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
