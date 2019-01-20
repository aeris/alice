class DiffsController < ApplicationController
	def index
		last = Diff.order(created_at: :desc).limit(1).first
		return redirect_to action: :show, id: last.created_at.to_date if last
	end

	DATE_DELTA = 3

	def show
		@date = Date.parse params[:id]
		dates = Diff.dates
		current = dates.index @date
		min = [0, current - DATE_DELTA].max
		max = current + DATE_DELTA
		@dates = dates[min..max]
		@diffs = Diff.where created_at: @date..@date+1
	end
end
