class SoundtracksController < ApplicationController
  require 'set'

  before_action :logged_in_user
  before_action :admin_user

  def index
    @open_events = Event.where("is_open = true")
    @soundtracks = Soundtrack.paginate(page: params[:page])
  end

  def new
    @open_events = Event.where("is_open = true")
    @soundtrack  = Soundtrack.new
    @songs       = Song.all.collect{|s| [s.song_by_artist, s.id]}
  end

  def create
    @songs            = params[:soundtrack][:songs] || []
    @soundtrack       = Soundtrack.new(soundtrack_params)
    @soundtrack.songs = Song.where(id: @songs.map{|song_id| song_id.to_i})
    if @soundtrack.save
      flash[:success] = "Soundtrack created successfully!"
      redirect_to soundtracks_url
    else
      @open_events    = Event.where("is_open = true")
      @songs          = Song.all.collect{|s| [s.song_by_artist, s.id]}
      render 'new'
    end
  end

  def edit
    @open_events      = Event.where("is_open = true")
    @soundtrack       = Soundtrack.find(params[:id])
    @soundtrack_songs = Set.new(@soundtrack.songs)
    @songs            = Song.all.collect do |s|
      if @soundtrack.songs.include? s
        [s.song_by_artist, s.id, {selected: true}]
      else
        [s.song_by_artist, s.id]
      end
    end
  end

  def update
    @songs            = params[:soundtrack][:songs] || []
    @soundtrack       = Soundtrack.find(params[:id])
    @soundtrack.songs = Song.where(id: @songs.map{|song_id| song_id.to_i})
    if @soundtrack.update_attributes(soundtrack_params)
      flash[:success] = "Soundtrack Updated!"
      redirect_to soundtracks_url
    else
      render 'edit'
    end
  end

  def destroy
    Soundtrack.find(params[:id]).destroy
    flash[:success] = "Soundtrack Deleted."
    redirect_to soundtracks_url
  end

  def import
    @open_events      = Event.where("is_open = true")
  end

  def process_import
    Soundtrack.import(params[:file], params[:soundtrack])
    flash[:success] = "Songs imported!"
    redirect_to soundtracks_url
  end

  private
    def soundtrack_params
      params.require(:soundtrack).permit(:name)
    end
end
