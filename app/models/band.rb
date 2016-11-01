class Band < ActiveRecord::Base
  has_many :members
  has_many :users, through: :members, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def is_member?(member_id)
    self.members.exists?(user_id: member_id)
  end
end
