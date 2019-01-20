class SitesController < ApplicationController
	def index
		@sites = Site.all.distinct.order(:group_id, :url)
	end

	def show
		@site = Site.find params[:id]
	end
end
