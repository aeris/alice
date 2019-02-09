class TemplatesController < ApplicationController
	before_action :set_template, only: [:edit, :update, :destroy]

	def new
		@template = ::Template.new
	end

	def create
		@template = ::Template.new(template_params)
		if @template.save
			redirect_to config_index_path, notice: 'Template has been successfully created.'
		else
			render :new
		end
	end

	def edit
	end

	def update
		if @template.update(template_params)
			redirect_to config_index_path, notice: 'Template has been successfully updated.'
		else
			render :edit
		end
	end


	def destroy
		@template.destroy
		redirect_to config_index_path, notice: 'Template has been successfully removed.'
	end

	private
		def set_template
			@template = ::Template.find(params[:id])
		end

		def template_params
			params.require(:template).permit(
				:id, :name,
				targets_attributes: %i[id name css from to group_id _destroy],
			)
		end
end
