class Member < ActiveRecord::Base
  belongs_to :User
  belongs_to :Band
end
