class Song < ActiveRecord::Base
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :soundtracks

  validates :name, presence: true
  validates :artists, presence: true
end
