class Notification < ActiveRecord::Base
  belongs_to :band
  belongs_to :user_id, class_name: "User"
  belongs_to :creator_id, class_name: "User"
end
