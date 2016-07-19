class SongRequestsController < ApplicationController
  before_action :logged_in_user, only: [:create, :toggle_completed]
  before_action :admin_user,     only: [:toggle_completed]
  before_action :correct_params, only: [:create]

  def create
    @request = SongRequest.new(request_params)
    if @request.save
      flash[:success] = "Song added successfully!"
      redirect_to event_url(params[:song_request][:event_id])
    else
      redirect_to events_url
    end
  end

  # Toggles a song request finishing.
  def toggle_completed
    @request = SongRequest.find(params[:id])

    @request.update(is_completed: true)

    flash[:success] = "Song Completed!"

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
      params.require(:song_request).permit(:song, :artist, :band_id, :event_id)
    end
end
