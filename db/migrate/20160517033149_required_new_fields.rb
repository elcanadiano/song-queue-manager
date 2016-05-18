class RequiredNewFields < ActiveRecord::Migration
  def up
    change_column :members,  :is_admin,     :boolean, null: false, default: false
    change_column :bands,    :name,         :string,  null: false
    change_column :requests, :song,         :string,  null: false
    change_column :requests, :artist,       :string,  null: false
    change_column :requests, :order,        :integer, null: false, default: 0
    change_column :requests, :is_completed, :boolean, null: false, default: false
    change_column :events,   :name,         :string,  null: false
    change_column :events,   :date,         :date,    null: false
    change_column :events,   :has_started,  :boolean, null: false, default: false
    change_column :events,   :is_completed, :boolean, null: false, default: false
  end

  def down
    change_column :members,  :is_admin,     :boolean
    change_column :bands,    :name,         :string
    change_column :requests, :song,         :string
    change_column :requests, :artist,       :string
    change_column :requests, :order,        :integer
    change_column :requests, :is_completed, :boolean
    change_column :events,   :name,         :string
    change_column :events,   :date,         :date
    change_column :events,   :has_started,  :boolean
    change_column :events,   :is_completed, :boolean
  end
end
