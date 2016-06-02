class Notification < ActiveRecord::Base
  belongs_to :band
  belongs_to :user,    class_name: "User", foreign_key: "user_id"
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
end
