class Request < ActiveRecord::Base
  belongs_to :Event
  belongs_to :Band
end
