class BandsController < ApplicationController
  before_action :logged_in_user,  only: [:new, :create, :edit, :update, :show, :invite, :create_invite]
  before_action :band_admin_user, only: [:edit, :update, :invite, :create_invite]
  before_action :existing_user,   only: [:create_invite]
  before_action :existing_member, only: [:create_invite]

  def new
    @band = Band.new
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
    @band = Band.find(params[:id])
    @members = Member.where({
      band_id: @band.id
    })
    @current_member = Member.find_by({
      band_id: @band.id,
      user_id: current_user.id
    })
  end

  def invite
    @band = Band.find(params[:id])
    @notification = Notification.new
  end

  def create_invite
    @band = Band.find(params[:id])
    @notification = Notification.new({
      user_id: params[:notification][:user_id],
      band_id: @band.id,
      creator_id: current_user.id
    })

    if @notifcation.save
      flash[:success] = "Invite sent!"
      redirect_to 'show'
    else
      render 'invite'
    end
  end

  private

    def band_params
      params.require(:band).permit(:name)
    end

    def existing_user
      puts "Meow."
      user = User.find_by(id: params[:notification][:user_id])

      if user.nil?
        flash[:danger] = "User not found or does not exist."
        redirect_to invite_band_url
      end
    end

    def existing_member
      member = Member.find_by({
        band_id: @band.id,
        user_id: params[:notification][:user_id]
      })

      if !member.nil?
        flash[:danger] = "This user is already a member of the band."
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
