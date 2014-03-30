class HomeController < ApplicationController
	def index
    if current_user
      redirect_to user_path
      #render :index, layout: true
    else
      render :signup, layout: nil
    end
	end

	def auth
		render json:request.env["omniauth.auth"]
		@user = find_by
	end
end
