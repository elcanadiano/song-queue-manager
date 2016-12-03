class SongRequestsController < ApplicationController
  before_action :logged_in_user,     only: [:create, :toggle_completed, :toggle_abandoned]
  before_action :admin_user,         only: [         :toggle_completed, :toggle_abandoned]
  before_action :is_member_or_admin, only: [:create]
  before_action :open_event,         only: [:create]

  #{"utf8"=>"✓", "authenticity_token"=>"8PyZ5j9vS8iT6Mkz+D1p2TnkMEZ77QfRdraVr/yaOD3logj7r18WHq6SpFd2fbY2lL4+KTHjXVkRuwruz/eL0A==",
  #"song_request"=>{"song"=>"535", "band_id"=>"3", "event_id"=>"1"}, "new_band"=>"assfdgsfgsergsergsergers", "commit"=>"Create my account",
  #"controller"=>"song_requests", "action"=>"create"}

  def create
    @song              = params[:song_request][:song].to_i || 0
    @song_request      = SongRequest.new(request_params)
    @song_request.song = Song.find_by(id: @song)

    if admin? && params[:song_request][:band_id] == "0"
      band = Band.find_or_create_by(name: params[:new_band])
    else
      band = Band.find_by(id: params[:song_request][:band_id])
    end

    @song_request.band = band

    if @song_request.save
      flash[:success] = "Song added successfully!"
      redirect_to event_url(params[:song_request][:event_id])
    else
      extra_zero   = admin? ? [["New Band", 0]] : []
      @open_events = Event.where("is_open = true")
      @bands       = admin? ? Band.all : current_user.bands
      @bands       = extra_zero + @bands.collect{|b| [b.name, b.id]}
      render 'events/song_request'
    end
  end

  # Toggles a song request finishing.
  def toggle_completed
    @request = SongRequest.find(params[:id])

    if @request.is_abandoned
      flash[:danger] = "The song is already abandoned."
    elsif @request.is_completed
      flash[:danger] = "The song is already completed."
    else
      @request.update(is_completed: true)

      flash[:success] = "Song Completed!"
    end

    redirect_to event_url(@request.event_id)
  end

  # Toggles a song request being abandoned.
  def toggle_abandoned
    @request = SongRequest.find(params[:id])

    if @request.is_abandoned
      flash[:danger] = "The song is already abandoned."
    elsif @request.is_completed
      flash[:danger] = "The song is already completed."
    else
      @request.update(is_abandoned: true)

      flash[:success] = "Song Abandoned!"
    end

    redirect_to event_url(@request.event_id)
  end

  private
    # Throws an error if the user is not an admin and is not part of the band.
    def is_member_or_admin
      if !admin?
        @member = Member.find_by({
          band_id: params[:song_request][:band_id],
          user_id: current_user.id
        })

        if @member.nil?
          flash[:danger] = "This user is not a member of the band."
          redirect_to events_url
        end
      end
    end

    def request_params
      params.require(:song_request).permit(:band_id, :event_id)
    end

    # Confirms an event is open.
    def open_event
      @event = Event.find(params[:song_request][:event_id])

      if !@event.is_open
        flash[:danger] = "We're sorry, but this event is not open for requests."
        redirect_to events_url
      end
    end
end
