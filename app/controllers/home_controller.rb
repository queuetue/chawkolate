class HomeController < ApplicationController
	def index
	end

	def auth
		render json:request.env["omniauth.auth"]
		@user = find_by
	end
end
