class SongsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
  before_action :has_artists, only: [:new]

  def index
    @open_events = Event.where("is_open = true")
    @songs       = Song.paginate(page: params[:page])
  end

  def new
    @open_events = Event.where("is_open = true")
    @song        = Song.new
  end

  def create
    @song         = Song.new(song_params)
    @song.artists = Artist.where(name: params[:song][:artists].split(";"))
    if @song.save
      flash[:success] = "Song created successfully!"
      redirect_to songs_url
    else
      render 'new'
    end
  end

  def edit
    @open_events  = Event.where("is_open = true")
    @song         = Song.find(params[:id])
    @artist_names = @song.artists.map{|a| a.name}.join(';')
  end

  def update
    @song         = Song.find(params[:id])
    @song.artists = Artist.where(name: params[:song][:artists].split(";"))
    if @song.update_attributes(song_params)
      flash[:success] = "Song Updated!"
      redirect_to songs_url
    else
      render 'edit'
    end
  end

  def destroy
    Song.find(params[:id]).destroy
    flash[:success] = "Song Deleted."
    redirect_to songs_url
  end

  private
    # You can only proceed to create a song if there is an artist.
    def has_artists
      if Artist.all.blank?
        flash[:warning] = "There needs to be at least one artist in the database."
        redirect_to artists_url
      end
    end

    def song_params
      params.require(:song).permit(:name)
    end
end
