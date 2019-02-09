class SitesController < ApplicationController
	before_action :set_group, only: [:edit, :update, :destroy]
	def index
		@sites = Site.all.includes(:group).order(:group_id, :url)
	end

	def show
		@site = Site.find params[:id]
	end
end
