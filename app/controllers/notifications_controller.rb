class NotificationsController < ApplicationController
  before_action :logged_in_user,             only: [:index,  :accept, :decline]
  before_action :correct_notification_user,  only: [:accept, :decline]
  before_action :check_expired_notification, only: [:accept, :decline]

  def index
    @user = current_user
    @notifications = Notification.where(user_id: current_user.id).order(:has_expired)
  end

  def accept
    @user = current_user

    @notification = Notification.find_by(id: params[:id])

    @notification.update(has_expired: true)

    @member = Member.create!({
      user_id: @user.id,
      band_id: @notification.band_id
    })

    flash[:success] = "Congratulations! You have joined #{@notification.band.name}!"

    redirect_to band_url(@notification.band_id)
  end

  def decline
    @notification = Notification.find_by(id: params[:id])
    @notification.update(has_expired: true)

    flash[:success] = "You have declined to join #{@notification.band.name}!"

    redirect_to notifications_url
  end

  private
    # Confirms the accept or decline of a notification is done by the correct user.
    def correct_notification_user
      @user = current_user
      @notification = Notification.find_by(id: params[:id])
      if @notification.nil? || @notification.user_id != @user.id
        flash[:danger] = "The notification is invalid."
        redirect_to(root_url)
      end
    end

    # Cannot accept or decline an expired notification.
    def check_expired_notification
      @notification = Notification.find_by(id: params[:id])

      if @notification.has_expired
        flash[:danger] = "You cannot accept or decline an expired notification."
        redirect_to(notifications_url)
      end
    end
end
