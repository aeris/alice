class DiffsController < ApplicationController
	def index
		last = Diff.order(created_at: :desc).limit(1).first
		return redirect_to action: :show, id: last.created_at.to_date if last
	end

	def show
		@dates = Diff.select(:created_at).distinct
		@all_dates = []
		@dates.each do |d|
			@all_dates.push(d.created_at.to_date)
		end
		@date = Date.parse params[:id]
		@diffs = Diff.where created_at: @date..@date+1
	end
end
