class EventsController < ApplicationController
  #before_action :logged_in_user, only: [:new, :create, :edit, :update]
  before_action :admin_user,     only: [:new, :create, :edit, :update]

  def index
    @events = Event.paginate(page: params[:page])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:success] = "Event created successfully!"
      redirect_to events_url
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to events_url
    else
      render 'edit'
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :date)
    end
end
