class ArtistsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @open_events = Event.where("is_open = true")
    @artists     = Artist.paginate(page: params[:page])
  end

  def new
    @open_events = Event.where("is_open = true")
    @artist      = Artist.new
  end

  def create
    @artist      = Artist.new(artist_params)
    if @artist.save
      flash[:success] = "Artist created successfully!"
      redirect_to artists_url
    else
      render 'new'
    end
  end

  def edit
    @open_events = Event.where("is_open = true")
    @artist      = Artist.find(params[:id])
  end

  def update
    @artist      = Artist.find(params[:id])
    if @artist.update_attributes(artist_params)
      flash[:success] = "Artist Updated!"
      redirect_to artists_url
    else
      render 'edit'
    end
  end

  def destroy
    Artist.find(params[:id]).destroy
    flash[:success] = "Artist Deleted."
    redirect_to artists_url
  end

  private

    def artist_params
      params.require(:artist).permit(:name)
    end
end
