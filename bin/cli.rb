#!./bin/rails runner
require 'ostruct'
require 'optparse'

# Force resolution to avoid cycle in autoloading
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
	ap reference: fp(reference),
	   content: fp(content),
	   checked_at: item.checked_at,
	   changed_at: item.changed_at,
	   last_error: item.last_error

	if reference && content && reference != content
		puts Utils.diff reference, content
	end
end

class App < Thor
	desc 'check', 'Check given sites for changes'
	method_option :reset, type: :boolean, default: false, aliases: '-r', desc: 'Reset sites before check'
	method_option :debug, type: :boolean, default: false, aliases: '-d', desc: 'Activate debug'

	COLORS = {
			reference:          :blue,
			unchanged:          :green,
			previously_changed: :light_red,
			changed:            :red,
			error:              { background: :red }
	}.freeze

	def check(urls = nil)
		reset = options[:reset]
		debug = options[:debug]

		self.process urls do |site|
			site.reset! if reset
			result = site.check debug: debug
			color  = COLORS[result]
			result.to_s.colorize color
		end
	end

	desc 'read', 'Mark given sites as read'

	def read(urls = nil)
		self.process urls, &:read!
	end

	desc 'diff', 'Display diff of the given sites'

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

	desc 'recalculate', 'Recalculate state of given sites'
	method_option :debug, type: :boolean, default: false, aliases: '-d', desc: 'Activate debug'

	def recalculate(urls = nil)
		debug = options[:debug]
		self.process urls do |site|
			result = site.recalculate! debug: debug
			color  = COLORS[result]
			result.to_s.colorize color
		end
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
				rescue => e
					puts "#{url} #{e.to_s.colorize :red}"
				end
			end
		end
	end
end
App.start
