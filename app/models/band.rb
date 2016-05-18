class Band < ActiveRecord::Base
  has_many :users, through: :members
end
