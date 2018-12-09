class DiffsController < ApplicationController
	def index
		limit  = params.fetch :limit, 100
		offset = params.fetch :offset, 0

		@diffs = Diff.offset(offset).limit(limit)
						 .order(:created_at)
						 .includes(:site)
	end
end
