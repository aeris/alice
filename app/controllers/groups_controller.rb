class GroupsController < ApplicationController
	before_action :set_group, only: [:edit, :update, :destroy]

	def new
		@group = Group.new
	end

	def create
		@group = Group.new(group_params)
		if @group.save
			redirect_to config_index_path, notice: 'Group has been successfully created.'
		else
			render :new
		end
	end

	def edit
		@group = Group.find(params[:id])
	end

	def update
		if @group.update(group_params)
			redirect_to config_index_path, notice: 'Group has been successfully updated.'
		else
			render :edit
		end
	end


	def destroy
		@group.destroy
		redirect_to config_index_path, notice: 'Group has been successfully removed.'
	end

	private
		def set_group
			@group = Group.find(params[:id])
		end

		def group_params
			params.require(:group).permit(
				:id, :name, :template_id,
				targets_attributes: [:id, :name, :css, :from, :to, :_destroy],
				sites_attributes: [:id, :name, :url, :_destroy]
			)
		end

end
