class StaticPagesController < ApplicationController
  def home
    @open_events = Event.where("is_open = true")
  end

  def help
    @open_events = Event.where("is_open = true")
  end

  def about
    @open_events = Event.where("is_open = true")
  end
end
