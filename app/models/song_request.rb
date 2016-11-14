class SongRequest < ActiveRecord::Base
  belongs_to :event
  belongs_to :band
  belongs_to :song
  default_scope -> { order(created_at: :asc) }
  validates  :song, presence: true
end
