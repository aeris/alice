class Site < ApplicationRecord
	belongs_to :group, optional: true
	belongs_to :template, optional: true
	has_many :targets
	has_many :diffs

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

		begin
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
				self.diffs.create! content: diffs
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

	def check!
		grab    = self.grab
		content = grab.body
		self.update! name: grab.title unless self.name

		unless self.reference
			self.update! reference: content
			:reference
		else
			self.diff! self.reference, content
		end
	end
end
