class Member < ActiveRecord::Base
  validates_each :user_id, :band_id  do |record, attr, value|
    if Member.exists?(user_id: record.user_id, band_id: record.band_id)
        record.errors.add attr, 'This user is already part of the band.'
    end
  end

  belongs_to :user
  belongs_to :band

  def is_admin?
    self.is_admin
  end
end
