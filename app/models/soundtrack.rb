class Soundtrack < ActiveRecord::Base
  require 'csv'

  has_and_belongs_to_many :songs
  has_many :events
  default_scope -> { order(id: :asc) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.import(file, soundtrack_name)
    #puts "Soundtrack Name: #{soundtrack_name}"

    soundtrack = self.find_or_create_by(name: soundtrack_name)

    puts "Soundtrack: #{soundtrack} - Name: #{soundtrack_name}"

    CSV.foreach(file.path, headers: true, encoding: "windows-1252:utf-8") do |row|
      artist_name = row["Artist"].strip
      song_name   = (row["Title"] || row["Song Title"]).strip

      puts "Song: #{song_name} by #{artist_name}"
      artist = Artist.find_or_create_by(name: artist_name)
      songs  = Song.where(name: song_name)
      chosen_song = nil

      songs.each do |song|
        chosen_song = song if song.artists.include?(artist)
      end

      chosen_song ||= Song.create(name: song_name, artists: [artist])

      soundtrack.songs << chosen_song if !soundtrack.songs.include?(chosen_song)
    end

    puts "Songs: #{soundtrack.songs.length}"

    soundtrack.save
    soundtrack
  end
end
