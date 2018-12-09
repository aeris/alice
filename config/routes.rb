Rails.application.routes.draw do
	resources :diffs, only: %i[index]
end
