class Site < ApplicationRecord
	belongs_to :group, optional: true
	belongs_to :template, optional: true
	has_many :targets
	has_many :checks

	validates :url, presence: true

	def self.[](url)
		self.where(url: url).first
	end

	def grab
		Http.new self.url
	end

	def inherited_targets
		targets  = self.targets
		group    = self.group
		targets  += group.targets if group
		template = self.template
		targets  = template.targets if template
		targets
	end

	def create_checks!
		self.inherited_targets.each do |target|
			self.checks.create! target: target
		end
	end

	def reset!
		self.update! reference: nil, content: nil, checked_at: nil, changed_at: nil, last_error: nil
	end

	def reference!(content)
		self.update! reference: content, content: content, checked_at: Time.now, changed_at: nil, last_error: nil
	end

	def read!
		return unless self.content
		self.reference! self.content
	end

	def clear!
		self.update! content: nil, checked_at: Time.now, changed_at: nil, last_error: nil
	end

	def diff(context: 3, **kwargs)
		reference = self.reference
		content   = self.content
		Diffy::Diff.new reference, content, context: context, **kwargs
	end

	def changed?(reference, content, debug: false)
		checks = self.checks
		if checks.empty?
			if reference != content
				puts Utils.diff reference, content if debug
				return true
			end
			return false
		end

		checks.each do |check|
			changed = check.changed? reference, content, debug: debug
			return true if changed
		end

		false
	end

	def diff!(reference, content, debug: false)
		self.checked_at = Time.now
		state           = :unchanged

		begin
			changed = self.changed? reference, content, debug: debug
			if changed
				self.content    = content
				self.changed_at = self.checked_at
				state           = :changed
			end
			self.last_error = nil
		rescue => e
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
			self.reference! content
			return :reference
		else
			return self.diff! self.content, content, debug: debug
		end
	end

	def recalculate!(debug: false)
		reference  = self.reference
		content    = self.content || reference
		changed_at = self.changed_at
		state      = :unchanged

		changed = self.checks.find { |c| c.changed? reference, content, debug: debug }
		if changed
			state      = :changed
			changed_at ||= self.checked_at
		else
			changed_at = nil
		end

		self.update! reference: reference, content: content, changed_at: changed_at

		state
	end
end
