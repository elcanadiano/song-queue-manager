class Request < ActiveRecord::Base
  belongs_to :event
  belongs_to :band
  default_scope -> { order(created_at: :asc) }
end
