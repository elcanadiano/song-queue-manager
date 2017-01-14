class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private
    # Confirms a logged-out user.
    def logged_out_user
      if logged_in?
        flash[:danger] = "You are already logged in."
        redirect_to root_url
      end
    end

    # Confirms a logged-in user.
    def logged_in_user
      if !logged_in?
        respond_to do |format|
          format.json {
            render json: {
              status:  "danger",
              message: "Please log in."
            }.to_json,
            status: 401
          }
          format.html {
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
          }
        end
      end
    end

    # Confirms an admin user.
    def admin_user
      if !admin?
        respond_to do |format|
          format.json {
            render json: {
              status:  "danger",
              message: "This function requires administrator privileges."
            }.to_json,
            status: 403
          }
          format.html {
            flash[:danger] = "This function requires administrator privileges."
            redirect_to(root_url)
          }
        end
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) if !current_user?(@user)
    end
end
