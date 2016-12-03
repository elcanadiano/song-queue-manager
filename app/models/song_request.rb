class SongRequest < ActiveRecord::Base
  belongs_to :event
  belongs_to :band
  belongs_to :song
  default_scope -> { order(created_at: :asc) }

  # It seems to me that if you put required: true on the event/band/song, you
  # can put an invalid event/band/song into the request and it validates.
  validates  :song_id,  presence: true
  validates  :band_id,  presence: true
  validates  :event_id, presence: true
end
