class SiteController < ApplicationController
	def changes
		@changes = Site.where.not(changed_at: nil).order(:changed_at)
	end
end
