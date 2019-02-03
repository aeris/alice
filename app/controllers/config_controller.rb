class ConfigController < ApplicationController
	def index
		@groups = Group.all
		@templates = ::Template.all
		@sites = Site.where(group: nil).order(:name, :url)
	end
end
