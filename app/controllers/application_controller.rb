class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	def authenticated?
		session[:authenticated] == true
	end

	def must_be_authenticated
		unless authenticated?
			session[:redirect_to] = request.path
			redirect_to login_path
		end
	end
end
