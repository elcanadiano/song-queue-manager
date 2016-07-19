class RequestsController < ApplicationController
  before_action :logged_in_user, only: [:create]
  before_action :admin_user,     only: [:toggle_completed]
  before_action :correct_params, only: [:create]

  def create
    @request = Request.new(request_params)
    if @request.save
      flash[:success] = "Song added successfully!"
      redirect_to event_url(params[:request][:event_id])
    else
      redirect_to events_url
    end
  end

  # Toggles a song request finishing.
  def toggle_completed
    @request = Request.find(params[:id])

    @request.update(is_completed: true)

    flash[:success] = "Song Completed!"

    redirect_to event_url(@request.event_id)
  end

  private
    # Checks to see if the User ID passed in is correct and checks to see if the
    # user is a member is part of the band passed in.
    def correct_params
      @member = Member.find_by({
        band_id: params[:request][:band_id],
        user_id: current_user.id
      })

      if @member.nil?
        flash[:danger] = "This user is not a member of the band."
        redirect_to events_url
      end
    end

    def request_params
      params.require(:request).permit(:song, :artist, :band_id, :event_id)
    end
end
