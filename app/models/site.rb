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

	def reference!(content)
		self.update! reference: content, content: content, checked_at: Time.now, changed_at: nil, last_error: nil
		self.checks.each { |c| c.reference! content }
	end

	STATES = %i[unchanged changed error].freeze

	def update_state(current, state)
		current_index = STATES.index current
		state_index   = STATES.index state
		current_index < state_index ? state : current
	end

	def diff(context: 3, **kwargs)
		reference = self.reference
		content   = self.content
		Diffy::Diff.new reference, content, context: context, **kwargs
	end

	def diff!(content, debug: false)
		self.checked_at = Time.now
		state           = :unchanged

		begin
			reference = self.content
			checks    = self.checks
			if checks.empty?
				if reference != content
					puts Utils.diff reference, content if debug
					state = :changed
				end
			else
				checks.each do |check|
					check_state = check.diff! content, debug: debug
					state       = self.update_state state, check_state
				end
			end

			if state == :changed
				self.content    = content
				self.changed_at = self.checked_at
			end

			self.last_error = nil
		rescue => e
			$stderr.puts e
			self.last_error = e
		end

		self.save!
		state
	end

	def check(debug: false)
		reference = self.reference
		content   = self.grab.body
		unless reference
			self.reference! content
			return :reference
		else
			return self.diff! content, debug: debug
		end
	end

	def recalculate!(debug: false)
		state = :unchanged

		reference  = self.reference
		content    = self.content || reference
		changed_at = self.changed_at

		states = self.checks.collect { |c| c.recalculate! debug: debug }.uniq
		state  = :changed if states.include? :changed
		if states.empty? && reference != content
			state = :changed
			puts Utils.diff reference, content if debug
		end

		if state == :changed
			changed_at ||= self.checked_at
		else
			content    = nil
			changed_at = nil
		end

		self.update! reference: reference, content: content, changed_at: changed_at

		state
	end

	def read!
		return unless self.content
		self.reference! self.content
	end

	def reset!
		self.update! reference: nil, content: nil, checked_at: nil, changed_at: nil, last_error: nil
		self.checks.each &:clear!
	end
end
