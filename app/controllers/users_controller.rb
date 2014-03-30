require 'json'
class UsersController < ApplicationController
  def show
  	if current_user
  		render :dashboard
  	else
  		render :login
  	end

  end

  def create
	auth = request.env["omniauth.auth"]

	@oauth_current_user = User.find_or_create_by_provider_and_uid(auth['provider'], auth['uid'])

	flash[:notice] = "Authentication successful."
	redirect_to user_path

  end

  def destroy
  	@current_user.destroy
  	flash[:notice] = "Successfully deleted user."
  	redirect_to root_path
  end
end
