class Song < ActiveRecord::Base
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :soundtracks
  has_many                :song_requests, dependent: :destroy
  after_save              :update_song_by_artist
  default_scope -> { order(name: :asc) }

  validates :name, presence: true
  validates :artists, presence: true

  private
    # Provides a string that describes the song followed by the artist(s) of the
    # song. The rule engine for the artists is as follows.
    #
    # - If a song only has one artist, provide the artist name.
    # - If there are two artists, separate them with an "" and ".
    # - If there are more artists, separate with a ", " with the last one have
    #   an ", and " (Oxford comma)
    def update_song_by_artist
      if self.artists.size == 1
        artists_list = self.artists[0].name
      elsif self.artists.size == 2
        artists_list = self.artists.map{|a| a.name}.join(' and ')
      elsif self.artists.size > 2
        artists_list = self.artists.map{|a| a.name}.join(', ').gsub(/(.*)(, )(.*)/, '\1, and \3')
      end

      self.update_column(:song_by_artist, self.name + " by " + artists_list)
    end
end
