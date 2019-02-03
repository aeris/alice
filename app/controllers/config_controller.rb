class ConfigController < ApplicationController
	def index
		@groups = Group.all
		@templates = ::Template.all
		@targets = Target.all
		@sites = Site.all.order(:name, :url)
	end
end
