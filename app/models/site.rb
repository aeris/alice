class Site < ApplicationRecord
	belongs_to :group, optional: true
	belongs_to :template, optional: true
	has_many :targets

	validates :url, presence: true

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

	def diff(context: 3, **kwargs)
		reference = self.reference
		content   = self.content
		Diffy::Diff.new reference, content, context: context, **kwargs
	end

	def content_changed?(reference, content, debug: false)
		targets = self.all_targets
		if targets.empty?
			if reference != content
				puts Utils.diff reference, content if debug
				return true
			end
			return false
		end

		targets.each do |target|
			changed = target.content_changed? reference, content, debug: debug
			return true if changed
		end

		false
	end

	def diff!(reference, content, date: Time.now, debug: false)
		self.checked_at = date
		state           = :unchanged

		begin
			changed = self.content_changed? reference, content, debug: debug
			if changed
				self.reference  = content
				self.changed_at = self.checked_at
				state           = :changed
			end
			self.last_error = nil
		rescue => e
			raise
			$stderr.puts e
			self.last_error = e
			state           = :error
		end

		self.save!
		state
	end

	def check!(debug: false)
		grab    = self.grab
		content = grab.body
		self.update! name: grab.title unless self.name

		unless self.reference
			self.update! reference: content
			return :reference
		else
			return self.diff! self.reference, content, debug: debug
		end
	end
end
