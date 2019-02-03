Rails.application.routes.draw do
	resources :diffs, only: %i[index show]
	resources :sites, only: %i[index show]
	resources :config, only: %i[index]
	resources :groups, only: %i[new create edit update destroy]
end
