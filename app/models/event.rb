class Event < ActiveRecord::Base
  has_many   :song_requests, dependent: :destroy
  belongs_to :soundtrack
  default_scope -> { order(is_open: :asc, date: :desc) }
  validates  :soundtrack,    presence: true

  def is_open?
    self.is_open
  end
end
