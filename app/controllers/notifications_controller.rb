class NotificationsController < ApplicationController
  before_action :logged_in_user, only: [:index, :accept, :decline]

  def index
    @user = current_user
    @notifications = Notification.where(user_id: current_user.id).order(:has_expired)
  end

  def accept
    @user = current_user

    @notification = Notification.find_by(id: params[:id])
    @notification.toggle!(:has_expired)

    @member = Member.create!({
      user_id: @user.id,
      band_id: @notification.band_id
    })

    flash[:success] = "Congratulations! You have joined #{@notification.band.name}!"

    redirect_to band_url(@notification.band_id)
  end

  def decline
    @notification = Notification.find_by(id: params[:id])

    @notification.toggle!(:has_expired)

    flash[:success] = "You have declined to join #{@notification.band.name}!"

    redirect_to notifications_url
  end

  private
    # Confirms the accept or decline of a notification is done by the correct user.
    def correct_notification_user
      @user = current_user
      @notification = Notification.find_by(id: params[:id])
      redirect_to(root_url) if @notification.nil? || @notification.user_id != @user.id
    end
end
