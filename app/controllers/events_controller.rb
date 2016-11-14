class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :show, :toggle_open, :song_request]
  before_action :admin_user,     only: [:new, :create, :edit, :update, :toggle_open]
  before_action :open_event,     only: [:song_request]

  def index
    @open_events = Event.where("is_open = true")

    # Admins can see recently-created events on top whereas regular users won't
    # see it as recently-created.
    if admin?
      @recent    = Event.where("is_open = false AND created_at >= ?", Time.now - 1.hours)
      @closed    = Event.where("is_open = false AND created_at < ?", Time.now - 1.hours)
    else
      @closed    = Event.where("is_open = false")
    end
  end

  def new
    @open_events = Event.where("is_open = true")
    @event       = Event.new
    @soundtracks = soundtrack_list
  end

  def create
    @event            = Event.new(event_params)
    @event.soundtrack = Soundtrack.find_by(id: params[:event][:soundtrack].to_i)
    @soundtracks      = soundtrack_list
    if @event.save
      flash[:success] = "Event created successfully!"
      redirect_to events_url
    else
      render 'new'
    end
  end

  def show
    @open_events    = Event.where("is_open = true")
    @event          = Event.find(params[:id])
    @requests       = SongRequest.where({
      event_id: params[:id]
    })
    @request_counts = SongRequest.select("bands.id, bands.name, count(is_completed) AS request_count")
                                 .joins("INNER JOIN bands ON bands.id = song_requests.band_id")
                                 .where("is_completed = true AND is_abandoned = false AND event_id = #{params[:id]}")
                                 .group("bands.id")
                                 .reorder("request_count DESC, bands.name ASC")
  end

  def edit
    @open_events = Event.where("is_open = true")
    @event       = Event.find(params[:id])
    @soundtracks = soundtrack_list
  end

  def update
    @event            = Event.find(params[:id])
    @event.soundtrack = Soundtrack.find_by(id: params[:event][:soundtrack].to_i)
    @soundtracks      = soundtrack_list
    if @event.update_attributes(event_params)
      flash[:success] = "Event Updated!"
      redirect_to events_url
    else
      render 'edit'
    end
  end

  # Song request page.
  def song_request
    @open_events  = Event.where("is_open = true")
    @event        = Event.find(params[:id])
    @bands        = current_user.bands
    @song_request = SongRequest.new

    # Redirect to the bands page for the user if said user is not part of a
    # band.
    if @bands.blank?
      flash[:warning] = "You must create or be part of a band in order to make a request."
      redirect_to bands_user_url(current_user)
    end
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

    # Returns a selection for song list.
    def soundtrack_list
      Soundtrack.all.collect do |s|
        if @event.soundtrack == s
          ["#{s.id} - #{s.name}", s.id, {selected: true}]
        else
          ["#{s.id} - #{s.name}", s.id]
        end
      end
    end
end
