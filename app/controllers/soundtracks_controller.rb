class SoundtracksController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @open_events = Event.where("is_open = true")
    @soundtracks = Soundtrack.paginate(page: params[:page])
  end

  def new
    @open_events = Event.where("is_open = true")
    @soundtrack  = Soundtrack.new
    @songs       = Song.all.collect{|s| [s.name, s.id]}
  end

  def create
    @soundtrack       = Soundtrack.new(soundtrack_params)
    @soundtrack.songs = Song.where(id: params[:soundtrack][:songs].map{|song_id| song_id.to_i})
    if @soundtrack.save
      flash[:success] = "Soundtrack created successfully!"
      redirect_to soundtracks_url
    else
      render 'new'
    end
  end

  def edit
    @open_events  = Event.where("is_open = true")
    @soundtrack   = Soundtrack.find(params[:id])
    @songs        = Song.all.collect do |s|
      if @soundtrack.songs.include? s
        [s.name, s.id, {selected: true}]
      else
        [s.name, s.id]
      end
    end
  end

  def update
    @soundtrack       = Soundtrack.find(params[:id])
    @soundtrack.songs = Song.where(id: params[:soundtrack][:songs].map{|song_id| song_id.to_i})
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

  private
    def soundtrack_params
      params.require(:soundtrack).permit(:name)
    end
end