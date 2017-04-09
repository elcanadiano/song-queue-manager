class SongRequestsController < ApplicationController
  before_action :logged_in_user,     only: [:create, :toggle_completed, :toggle_abandoned, :toggle_started, :reorder]
  before_action :admin_user,         only: [         :toggle_completed, :toggle_abandoned, :toggle_started, :reorder]
  before_action :is_member_or_admin, only: [:create]
  before_action :open_event,         only: [:create]

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

    if @request.abandoned?
      flash[:danger] = "The song is already abandoned."
    elsif @request.completed?
      flash[:danger] = "The song is already completed."
    elsif @request.request?
      flash[:danger] = "The song needs to be in progress before it can be " +
      "marked as completed."
    else
      @request.update(status: :completed)

      last_song_position = Event.find(@request.event_id).song_order - 1
      reorder_song_request(@request.id, last_song_position)

      flash[:success] = "Song Completed!"
    end

    redirect_to event_url(@request.event_id)
  end

  # Marks a song as in progress.
  def toggle_started
    @request = SongRequest.find(params[:id])

    if @request.abandoned?
      flash[:danger] = "The song is already abandoned."
    elsif @request.completed?
      flash[:danger] = "The song is already completed."
    elsif @request.in_progress?
      flash[:danger] = "The song is already in progress."
    else
      # Updates any song currently in progress to completed.
      last_song_position = Event.find(@request.event_id).song_order - 1

      SongRequest.in_progress.where(event_id: @request.event_id).each do |request|
        request.update(status: :completed)
        reorder_song_request(@request.id, last_song_position)
      end

      @request.update(status: :in_progress)

      # Move the current song to the top.
      reorder_song_request(@request.id, 0)

      flash[:success] = "Song Started!"
    end

    redirect_to event_url(@request.event_id)
  end

  # Toggles a song request being abandoned.
  def toggle_abandoned
    @request = SongRequest.find(params[:id])

    if @request.abandoned?
      flash[:danger] = "The song is already abandoned."
    elsif @request.completed?
      flash[:danger] = "The song is already completed."
    else
      @request.update(status: :abandoned)

      last_song_position = Event.find(@request.event_id).song_order - 1
      reorder_song_request(@request.id, last_song_position)

      flash[:success] = "Song Abandoned!"
    end

    redirect_to event_url(@request.event_id)
  end

  # Given a Request ID and the index it should be updated to, updates the order
  # to the new index and updates the other ones accordingly.
  def reorder
    begin
      request_id = params["request_id"].to_i
      new_index  = params["new_index"].to_i
      reorder_song_request(request_id, new_index)


      respond_to do |format|
        format.json {
          render json: {
            status:  "success",
            message: "Order saved successfully!"
          }.to_json
        }
      end
    rescue
      respond_to do |format|
        format.json {
          render json: {
            status:  "danger",
            message: "An error has occured. If this error persists, please " +
            "contact the administrator."
          }.to_json,
          status: 422
        }
      end
    end
  end

  private
    # Reorders the song request and returns a status code.
    def reorder_song_request(request_id, new_index)
      # Get the request the ID is pertaining to.
      request = SongRequest.find(request_id)

      # Is the new index greater than the current ID's index? If so, find the
      # records with indexes between the current's + 1 until the new_index and
      # decrement those song_order values by 1. Set current request to the new
      # index. Otherwise, do the opposite.

      if new_index > request.song_order
        other_requests = SongRequest.where(event_id: request.event_id, song_order: request.song_order + 1..new_index)
        .update_all("song_order = song_order - 1")
        request.update_columns(song_order: new_index)
      elsif new_index < request.song_order
        other_requests = SongRequest.where(event_id: request.event_id, song_order: new_index..request.song_order - 1)
        .update_all("song_order = song_order + 1")
        request.update_columns(song_order: new_index)
      end
    end

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
