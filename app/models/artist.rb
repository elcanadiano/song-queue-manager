class Artist < ActiveRecord::Base
  has_and_belongs_to_many :songs
  validates :name, presence: true, uniqueness: { case_sensitive: false }

end
