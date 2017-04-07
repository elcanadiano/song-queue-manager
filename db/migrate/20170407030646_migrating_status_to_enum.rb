class MigratingStatusToEnum < ActiveRecord::Migration
  def up
    add_column    :song_requests, :status, :integer, default: 0, null: false

    SongRequest.all.each do |request|
      if request.is_completed
        request.update!(status: :completed)
      elsif request.is_abandoned
        request.update!(status: :abandoned)
      end
    end

    remove_column :song_requests, :is_completed
    remove_column :song_requests, :is_abandoned
  end

  # WARNING: There is no representation for a song "In Progress" in the old data
  # model. Songs "In Progress" will become a song that is not abandoned nor
  # completed. Therefore, data will be lost.
  def down
    add_column :song_requests, :is_completed, :boolean, default: false, null: false
    add_column :song_requests, :is_abandoned, :boolean, default: false, null: false

    SongRequest.all.each do |request|
      if request.completed?
        request.update!(is_completed: true)
      elsif request.abandoned?
        request.update!(is_abandoned: true)
      end
    end

    remove_column :song_requests, :status
  end
end
