class SongRequest < ActiveRecord::Base
  belongs_to :event
  belongs_to :band
  belongs_to :song
  default_scope -> { order(song_order: :asc) }

  enum status: {
    request:     0,
    in_progress: 1,
    completed:   2,
    abandoned:   -1,
  }

  # It seems to me that if you put required: true on the event/band/song, you
  # can put an invalid event/band/song into the request and it validates.
  validates  :song_id,  presence: true
  validates  :band_id,  presence: true
  validates  :event_id, presence: true

  before_create :set_order

  private
  	# Before a Request is made, we set its song order, which can be retrieved
  	# from the related event. Increment the event's order.
    def set_order
    	self.song_order = self.event.song_order
    	self.event.update_column(:song_order, self.event.song_order + 1)
    end
end
