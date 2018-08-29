#!./bin/rails runner
require 'ostruct'
require 'optparse'

# Force resolution to avoid cycle in autoloading
Http
Check
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
	desc 'check <url>*', 'Check given sites for changes'
	method_option :reset, type: :boolean, default: false, aliases: '-r', desc: 'Reset sites before check'
	method_option :debug, type: :boolean, default: false, aliases: '-d', desc: 'Activate debug'

	COLORS = {
			reference: :blue,
			unchanged: :green,
			changed:   :red,
			error:     { background: :red }
	}.freeze

	def check(urls = nil)
		reset = options[:reset]
		debug = options[:debug]

		results = Hash.new 0

		self.process urls do |site|
			site.reset! if reset
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

	desc 'clear <url>*', 'Clear given sites'

	def clear(urls = nil)
		self.process urls, &:clear!
	end

	desc 'diff <url>*', 'Display diff of the given sites'

	def diff(urls = nil)
		sites = self.sites urls
		sites.each do |site|
			next unless site.changed_at
			puts "#{site.url.colorize :yellow}"
			checks = site.checks
			display site if checks.empty?
			checks.each do |check|
				next unless check.changed_at
				puts "  #{check.target}"
				display check
			end
		end
	end

	desc 'recalculate <url>*', 'Recalculate state of given sites'
	method_option :debug, type: :boolean, default: false, aliases: '-d', desc: 'Activate debug'

	def recalculate(urls = nil)
		debug = options[:debug]
		results = Hash.new 0

		self.process urls do |site|
			result = site.recalculate! debug: debug
			color  = COLORS[result]
			results[result] += 1
			result.to_s.colorize color
		end

		results.each do |k, v|
			color = COLORS[k]
			puts "#{k.to_s.colorize color}: #{v}"
		end
	end

	desc 'reset <url>*', 'Reset state of given sites'

	def reset(urls = nil)
		self.process urls, &:reset!
	end

	desc 'redo <url> <date1> <date2>', 'Redo check from cache'

	def redo(url, date1 = nil, date2 = nil)
		site      = Site.where(url: url).first
		fp        = Digest::SHA256.hexdigest url
		dir       = File.join Rails.root, 'tmp/cache/http'
		reference = File.join dir, "#{fp}_#{date1}"
		reference = File.read reference
		content   = File.join dir, "#{fp}_#{date2}"
		content   = File.read content

		ap site.changed? reference, content, debug: true
	end

	protected

	def sites(url)
		return Site.where url: url if url
		Site.all
	end

	def process(urls)
		sites = self.sites urls
		Parallel.each sites, in_threads: 16 do |site|
			ActiveRecord::Base.transaction do
				url = site.url.colorize :yellow
				begin
					result = yield site
					puts "#{url} #{result}"
					result
				rescue => e
					puts "#{url} #{e.to_s.colorize :red}"
					nil
				end
			end
		end
	end
end
App.start
