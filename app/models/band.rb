class Band < ActiveRecord::Base
  has_many :members
  has_many :users, through: :members, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
