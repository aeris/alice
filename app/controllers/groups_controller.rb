class GroupsController < ApplicationController
	before_action :set_group, only: %i[edit update destroy]
	before_action :must_be_authenticated, only: %i[new create edit update destroy]

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
			@group = Group.find params[:id]
		end

		def group_params
			params.require(:group).permit(
				:id, :name, :template_id,
				targets_attributes: %i[id name css from to group_id _destroy],
				sites_attributes: %i[id name url group_id _destroy]
			)
		end

end
