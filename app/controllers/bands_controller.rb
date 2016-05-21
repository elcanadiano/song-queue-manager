class BandsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create]
  #before_action :correct_user, only: [:create]

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

  private

    def band_params
      params.require(:band).permit(:name)
    end
end
