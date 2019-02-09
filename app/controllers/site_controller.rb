class SiteController < ApplicationController
	def login
	end

	def auth
		if params[:username] == ENV['LOGIN_USERNAME'] && params[:password] == ENV['LOGIN_PASSWORD']
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
