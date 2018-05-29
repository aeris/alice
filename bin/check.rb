#!./bin/rails runner
Parallel.each Site.all, in_threads: 5 do |site|
	ActiveRecord::Base.transaction do
		print "Checking #{site.url.colorize :yellow}..."
		begin
			result = site.check
			color  = case result
					 when :new
						 :blue
					 when :changes
						 :green
					 end
			puts " #{result.to_s.colorize color}"
		rescue => e
			puts " #{e.to_s.colorize :red}"
		end
	end
end
