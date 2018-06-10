#!./bin/rails runner
# id = ARGV.first
# check = Check.find id
# reference = File.join Dir.tmpdir, "#{id}-reference"
# File.write reference, check.reference
# content = File.join Dir.tmpdir, "#{id}-content"
# File.write content, check.content
# system 'kompare', reference, content

# puts 'Recalculating...'
# Site.all.each do |site|
# 	puts site.url.colorize :yellow
# 	site.checks.each do |check|
# 		puts '  ' + check.target.to_s
# 		check.recalculate!
# 	end
# end

def fp(content)
	return nil unless content
	Digest::SHA1.hexdigest content
end

def display(item)
	reference = item.reference&.force_encoding 'utf-8'
	content   = item.content&.force_encoding 'utf-8'
	ap reference: fp(reference),
	   content: fp(content),
	   checked_at: item.checked_at,
	   changed_at: item.changed_at,
	   last_error: item.last_error

	if reference && content && reference != content
		diff = Diffy::Diff.new reference, content, context: 3
		diff = diff.to_s :color
		if diff.lines.size > 30
			puts '...(too much diff)...'.colorize :light_red
		else
			puts diff
		end
	end
end

url   = ARGV.first
sites = if url
			if url == 'all'
				Site.all
			else
				Site.where url: url
			end
		else
			Site.where.not changed_at: nil
		end

sites.each do |site|
	site.recalculate!
	next unless site.changed_at
	puts site.url.colorize :yellow
	checks = site.checks
	display site if checks.empty?
	checks.each do |check|
		# check.recalculate!
		next unless check.changed_at
		puts "  #{check.target}"
		display check
	end
end
