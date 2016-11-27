class Band < ActiveRecord::Base
  has_many :members, dependent: :destroy
  has_many :users, through: :members
  has_many :song_requests, dependent: :destroy
  has_many :notifications, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def is_member?(member_id)
    self.members.exists?(user_id: member_id)
  end
end
