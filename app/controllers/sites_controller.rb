class SitesController < ApplicationController
	before_action :set_site, only: %i[show edit update destroy]
	before_action :must_be_authenticated, only: %i[new create edit update destroy]

	def index
		@sites = Site.all.includes(:group).order(:group_id, :url)
	end

	def show
	end

	def new
		@site = Site.new
	end

	def create
		@site = Site.new(site_params)
		if @site.save
			redirect_to config_index_path, notice: 'Site has been successfully created.'
		else
			render :new
		end
	end

	def edit
	end

	def update
		if @site.update(site_params)
			redirect_to config_index_path, notice: 'Site has been successfully updated.'
		else
			render :edit
		end
	end


	def destroy
		@site.destroy
		redirect_to config_index_path, notice: 'Site has been successfully removed.'
	end

	private
		def set_site
			@site = Site.find params[:id]
		end

		def site_params
			params.require(:site).permit(
				:id, :name, :url, :template_id, :group_id,
				targets_attributes: %i[id name css from to site_id _destroy]
			)
		end
end
