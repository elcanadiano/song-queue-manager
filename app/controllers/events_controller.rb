class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :show, :toggle_open, :song_request]
  before_action :admin_user,     only: [:new, :create, :edit, :update, :toggle_open]
  before_action :correct_params, only: [:create_invite]
  before_action :open_event,     only: [:song_request]

  def index
    @events = Event.paginate(page: params[:page])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:success] = "Event created successfully!"
      redirect_to events_url
    else
      render 'new'
    end
  end

  def show
    @event          = Event.find(params[:id])
    @requests       = SongRequest.where({
      event_id: params[:id]
    })
    @request_counts = SongRequest.select("bands.id, bands.name, count(is_completed) AS request_count")
                                 .joins("INNER JOIN bands ON bands.id = song_requests.band_id")
                                 .where("is_completed = true AND is_abandoned = false AND event_id = #{params[:id]}")
                                 .group("bands.id")
                                 .reorder("bands.id")
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(event_params)
      flash[:success] = "Profile updated"
      redirect_to events_url
    else
      render 'edit'
    end
  end

  # Song request page.
  def song_request
    @event = Event.find(params[:id])
    @bands = current_user.bands
    @song_request = SongRequest.new
  end

  # PATCH function to toggle an event being open/closed for requests.
  def toggle_open
    @event = Event.find(params[:id])
    @event.toggle! :is_open
    adj = @event.is_open? ? "open" : "closed"
    flash[:success] = "#{@event.name} is now #{adj} for requests!"
    redirect_to events_url
  end

  private

    def event_params
      params.require(:event).permit(:name, :date)
    end

    # Confirms an event is open.
    def open_event
      @event = Event.find(params[:id])

      if !@event.is_open
        flash[:danger] = "We're sorry, but this event is not open for requests."
        redirect_to events_url
      end
    end
end
