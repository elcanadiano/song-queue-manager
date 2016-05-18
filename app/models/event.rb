class Event < ActiveRecord::Base
  has_many :request
  default_scope -> { order(has_started: :asc, date: :desc) }
end
