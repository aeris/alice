class Site < ApplicationRecord
	belongs_to :group, optional: true
	belongs_to :template, optional: true
	has_many :targets, dependent: :delete_all
	has_many :diffs, dependent: :delete_all
	attribute :reference, :compressed_text

	validates :url, presence: true
	accepts_nested_attributes_for :targets, allow_destroy: true, reject_if: lambda{ |a| a[:name].blank? }

	def self.[](url)
		self.where(url: url).first
	end

	def grab
		Http.new self.url
	end

	def all_targets
		targets  = self.targets
		template = self.template
		targets  += template.all_targets if template
		group    = self.group
		targets  += group.all_targets if group
		targets
	end

	def diff(reference, content)
		targets = self.all_targets
		if targets.empty?
			[Diffy::Diff.diff(reference, content)]
		else
			targets.collect do |target|
				diff = target.diff reference, content
				next nil unless diff
				[target, diff]
			end
		end.compact
	end

	def diff!(reference, content, date: Time.now)
		self.checked_at = date
		state           = :unchanged

		diffs = self.diff reference, content
		unless diffs.empty?
			self.reference  = content
			self.changed_at = self.checked_at
			state           = :changed

			diffs = diffs.collect do |diff|
				case diff
				when Diffy::Diff
					{ diff: diff.dump }
				else
					target, diff = diff
					{
							target: target.to_h,
							diff:   diff.dump
					}
				end
			end
			self.diffs.create! content: diffs, created_at: date
		end
		self.last_error = nil

		self.save!
		state
	end

	def check!
		grab    = self.grab
		content = grab.body
		self.update! name: grab.title unless self.name

		status = unless self.reference
					 self.update! reference: content
					 :reference
				 else
					 self.diff! self.reference, content
				 end
		self.store content unless status == :unchanged

		status
	rescue => e
		$stderr.puts e
		self.update! checked_at: Time.now, last_error: e
		:error
	end

	def caches
		Dir["#{HTTP_CACHE_DIR}/#{self.prefix}_*.xz"].sort.collect do |file|
			name    = File.basename file
			date    = name.split('_', 2).last
			date    = DateTime.strptime date, DATE_FORMAT
			content = Html.to_s self.class.load file
			[date, content]
		end
	end

	protected

	def prefix
		Digest::SHA256.hexdigest self.url
	end

	def self.load(file)
		body = File.binread file
		XZ.decompress body
	end

	DATE_FORMAT    = '%Y%m%d_%H%M%S'.freeze
	HTTP_CACHE_DIR = File.join Rails.root, 'tmp', 'cache', 'http'
	FileUtils.mkdir_p HTTP_CACHE_DIR unless Dir.exist? HTTP_CACHE_DIR

	def store(content)
		return unless ENV['DEBUG_HTTP']

		prefix = self.prefix

		# last = Dir[File.join HTTP_CACHE_DIR, "#{prefix}_*.xz"].sort.last
		# if last
		# 	last = self.class.cache last
		# 	old  = Digest::SHA256.hexdigest last
		# 	new  = Digest::SHA256.hexdigest body
		# 	return if old == new
		# end

		time    = Time.now.strftime DATE_FORMAT
		file    = prefix + '_' + time + '.xz'
		file    = File.join HTTP_CACHE_DIR, file
		content = XZ.compress content, level: 9
		File.binwrite file, content
		file
	end
end
