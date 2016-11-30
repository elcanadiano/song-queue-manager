class SongRequestsController < ApplicationController
  before_action :logged_in_user, only: [:create, :toggle_completed, :toggle_abandoned]
  before_action :admin_user,     only: [         :toggle_completed, :toggle_abandoned]
  before_action :correct_params, only: [:create]
  before_action :open_event,     only: [:create]

  def create
    @song              = params[:song_request][:song].to_i || 0
    @song_request      = SongRequest.new(request_params)
    @bands             = current_user.bands
    @song_request.song = Song.find_by(id: @song)

    if @song_request.save
      flash[:success] = "Song added successfully!"
      redirect_to event_url(params[:song_request][:event_id])
    else
      @open_events = Event.where("is_open = true")
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
    # Checks to see if the current user is in fact a member of the band.
    def correct_params
      @member = Member.find_by({
        band_id: params[:song_request][:band_id],
        user_id: current_user.id
      })

      if @member.nil?
        flash[:danger] = "This user is not a member of the band."
        redirect_to events_url
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
