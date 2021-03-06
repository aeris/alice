Rails.application.routes.draw do
	resources :diffs, only: %i[index show]
	resources :sites, only: %i[index show new create edit update destroy]
	resources :config, only: %i[index]
	resources :groups, only: %i[new create edit update destroy]
	resources :templates, only: %i[new create edit update destroy]
	# resources :access, only: %i[new create]

	get '/login', to: 'site#login'
	post '/login', to: 'site#auth'
	get '/logout', to: 'site#logout'
end
