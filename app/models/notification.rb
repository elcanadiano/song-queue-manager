class Notification < ActiveRecord::Base
  # If there is a notification for the user and it was not accepted/declined
  validates_each :user_id, :band_id  do |record, attr, value|
    if Notification.exists?(user_id: record.user_id, band_id: record.band_id, has_expired: false)
      record.errors.add attr, 'This user already has an unexpired band invite for this band.'
    end
    if Member.exists?(user_id: record.user_id, band_id: record.band_id)
      record.errors.add attr, 'This user is already part of the band.'
    end
  end

  belongs_to :band
  belongs_to :user,    class_name: "User", foreign_key: "user_id"
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
end
