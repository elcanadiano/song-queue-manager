class Event < ActiveRecord::Base
  has_many :song_requests, dependent: :destroy
  default_scope -> { order(is_open: :asc, date: :desc) }

  def is_open?
    self.is_open
  end
end
