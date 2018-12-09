Rails.application.routes.draw do
	resources :diffs, only: %i[index show]
end
