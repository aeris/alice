class SiteController < ApplicationController
	def login
	end

	def auth
		if params[:username] == ENV["username"] && params[:password] == ENV["password"]
			session[:authenticated] = true
			redirect_to session[:redirect_to] || diffs_path
		else
			render :login
		end
	end

	def logout
		session[:authenticated] = false
		redirect_to :login
	end

end
