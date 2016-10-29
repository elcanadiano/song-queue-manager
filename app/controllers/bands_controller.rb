class BandsController < ApplicationController
  before_action :logged_in_user,      only: [:new, :create, :edit, :update, :show, :invite, :create_invite, :remove_member]
  before_action :band_admin_user,     only: [               :edit, :update,        :invite, :create_invite, :remove_member]
  before_action :existing_user,       only: [                                               :create_invite]
  before_action :existing_member,     only: [                                                               :remove_member]
  before_action :nonexisting_member,  only: [                                               :create_invite]
  before_action :cannot_remove_self,  only: [                                                               :remove_member]
  before_action :cannot_remove_admin, only: [                                                               :remove_member]
  before_action :nonexisting_invite,  only: [                                               :create_invite]
  before_action :correct_params,      only: [                                               :create_invite]

  def new
    @open_events = Event.where("is_open = true")
    @band        = Band.new
  end

  def create
    @band = Band.new(band_params)
    @user = current_user

    if @band.save
      # Make the band creator a member of the band and make them an admin.
      @band.users << @user
      Member.find_by({band_id: @band.id, user_id: @user.id}).toggle! :is_admin

      flash[:success] = "#{@band.name} created!"
      redirect_to bands_user_url @user.id
    else
      render 'new'
    end
  end

  def edit
    @open_events = Event.where("is_open = true")
  end

  def update
    @user = current_user

    if @band.update_attributes(band_params)
      flash[:success] = "Band updated!"
      redirect_to bands_user_url @user.id
    else
      render 'edit'
    end
  end

  def show
    @open_events    = Event.where("is_open = true")
    @band           = Band.find(params[:id])
    @members        = Member.where({
      band_id: @band.id
    })
    @current_member = Member.find_by({
      band_id: @band.id,
      user_id: current_user.id
    })
  end

  # Invite User Page
  def invite
    @open_events  = Event.where("is_open = true")
    @band         = Band.find(params[:id])
    @notification = Notification.new
  end

  # Creates an invite notification to the user.
  def create_invite
    @notification = Notification.new(notification_params)
    @notification.notification_type = 'invite'

    if @notification.save
      flash[:success] = "Invite sent!"
      redirect_to band_url(@band)
    else
      render 'invite'
    end
  end

  # Removes member from band.
  def remove_member
    Member.find_by(band_id: params[:id], user_id: params[:user_id]).destroy

    flash[:success] = "The user is no longer part of the band!"

    redirect_to band_url(params[:id])
  end

  private

    def band_params
      params.require(:band).permit(:name)
    end

    def notification_params
      params.require(:notification).permit(:user_id, :band_id, :creator_id)
    end

    def correct_params
      @band = Band.find(params[:id])

      if params[:notification][:band_id].to_i != @band.id || params[:notification][:creator_id].to_i != current_user.id
        flash[:danger] = "It has been detected that the parameters were incorrectly modified."
        redirect_to invite_band_url
      end
    end

    # Checks to see if the user exists. Barks if the user doesn't exist.
    def existing_user
      user = User.find_by(id: params[:notification][:user_id])

      if user.nil?
        flash[:danger] = "User not found or does not exist."
        redirect_to invite_band_url
      end
    end

    # Checks to see if the member does not exist. Barks if the member is NOT
    # part of the band (ie. pass if the member exists)
    def existing_member
      member = Member.find_by({
        band_id: @band.id,
        user_id: params[:user_id]
      })

      if member.nil?
        flash[:danger] = "This user not a member of the band."
        redirect_to band_url(@band)
      end
    end

    # Barks if you try to remove a fellow admin from the band.
    def cannot_remove_admin
      member = Member.find_by({
        band_id: @band.id,
        user_id: params[:user_id]
      })

      if member.is_admin?
        flash[:danger] = "You cannot remove an admin from the band. They must" +
        " step down first."
        redirect_to band_url(@band)
      end
    end

    # Barks if you try to remove yourself from the band.
    def cannot_remove_self
      if params[:user_id].to_i == current_user.id
        flash[:danger] = "You cannot remove yourself from the band."
        redirect_to band_url(@band)
      end
    end

    # Checks to see if the member exists. Barks if the member IS part of the
    # band (ie. pass if the member does not exist)
    def nonexisting_member
      member = Member.find_by({
        band_id: @band.id,
        user_id: params[:notification][:user_id]
      })

      if !member.nil?
        flash[:danger] = "This user is already a member of the band."
        redirect_to invite_band_url
      end
    end

    def nonexisting_invite
      notifications = Notification.find_by({
        band_id:           @band.id,
        user_id:           params[:notification][:user_id],
        notification_type: 'invite',
        has_expired:       false
      })

      if !notifications.nil?
        flash[:danger] = "An invite has been sent to this user already."
        redirect_to invite_band_url
      end
    end

    # Checks to see if the user has administration privileges as part of its
    # membership.
    def band_admin_user
      @band = Band.find(params[:id])
      @member = Member.find_by({
        band_id: @band.id,
        user_id: current_user.id
      })

      if !@member || !@member.is_admin?
        flash[:danger] = "You are not authorized to manage this band."
        redirect_to root_url
      end
    end
end
