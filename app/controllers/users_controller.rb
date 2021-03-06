class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:index, :edit, :update, :destroy]
  before_action :logged_out_user, only: [:new]
  before_action :correct_user,    only: [:edit, :update, :bands]
  before_action :admin_user,      only: :destroy

  def index
    @open_events = Event.where("is_open = true")
    @users       = User.paginate(page: params[:page])
  end

  def show
    @open_events = Event.where("is_open = true")
    @user        = User.find(params[:id])
  end

  def new
    @open_events = Event.where("is_open = true")
    @user        = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      @open_events = Event.where("is_open = true")
      render 'new'
    end
  end

  def edit
    @open_events = Event.where("is_open = true")
    @user        = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      @open_events = Event.where("is_open = true")
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
