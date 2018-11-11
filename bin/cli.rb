#!./bin/rails runner
require 'ostruct'
require 'optparse'

# Force resolution to avoid cycle in autoloading
Http
Target
Site
Group
Template

def fp(content)
	return nil unless content
	Digest::SHA1.hexdigest content
end

def display(item)
	reference = item.reference
	content   = item.content
	ap reference:  fp(reference),
	   content:    fp(content),
	   checked_at: item.checked_at,
	   changed_at: item.changed_at,
	   last_error: item.last_error

	if reference && content && reference != content
		puts Utils.diff reference, content
	end
end

class App < Thor
	COLORS = {
			reference: :blue,
			unchanged: :green,
			changed:   :red,
			error:     { background: :red }
	}.freeze

	desc 'check <url>*', 'Check given sites for changes'
	method_option :debug, type: :boolean, default: false, aliases: '-d', desc: 'Activate debug'


	def check(urls = nil)
		debug = options[:debug]

		results = Hash.new 0

		self.process urls do |site|
			result          = site.check! debug: debug
			results[result] += 1
			color           = COLORS[result]
			result.to_s.colorize color
		end

		results.each do |k, v|
			color = COLORS[k]
			puts "#{k.to_s.colorize color}: #{v}"
		end
	end

	desc 'read <url>*', 'Mark given sites as read'

	def read(urls = nil)
		self.process urls, &:read!
	end

	desc 'redo <url>*', 'Redo diff from cache'

	def redo(urls = nil)
		cache = 'tmp/cache/http'
		self.process urls do |site|
			site._changes.delete_all
			reference = nil
			fp        = Http.prefix site.url
			Dir["#{cache}/#{fp}_*"].sort.each do |file|
				name    = File.basename file
				date    = name.split('_', 2).last
				date    = DateTime.strptime date, Http::DATE_FORMAT
				content = File.read file

				unless reference
					site.update! reference: content
				else
					status = site.diff! reference, content, date: date
					ap site: site.url, date: date, status: status
				end
				reference = content
			end
			nil
		end
	end

	# desc 'redo <url> <date1> <date2>', 'Redo check from cache'
	#
	# def redo(url, date1 = nil, date2 = nil)
	# 	site      = Site.where(url: url).first
	# 	fp        = Digest::SHA256.hexdigest url
	# 	dir       = File.join Rails.root, 'tmp/cache/http'
	# 	reference = File.join dir, "#{fp}_#{date1}"
	# 	reference = File.read reference
	# 	content   = File.join dir, "#{fp}_#{date2}"
	# 	content   = File.read content
	#
	# 	ap site.changed? reference, content, debug: true
	# end

	protected

	def sites(url)
		return Site.where url: url if url
		Site.all
	end

	def process(urls)
		sites = self.sites urls
		Parallel.each sites, in_threads: 1 do |site|
			ActiveRecord::Base.transaction do
				url = site.url.colorize :yellow
				begin
					result = yield site
					puts "#{url} #{result}"
					result
				rescue => e
					puts "#{url} #{e.to_s.colorize :red}"
					raise
					nil
				end
			end
		end
	end
end
App.start
