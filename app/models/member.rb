class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :band

  def is_admin?
    self.is_admin
  end
end
