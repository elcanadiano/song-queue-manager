class Soundtrack < ActiveRecord::Base
  has_and_belongs_to_many :songs
  has_many :events
  default_scope -> { order(id: :asc) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
