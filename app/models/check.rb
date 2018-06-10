class Check < ApplicationRecord
	belongs_to :site
	belongs_to :target

	def reference!(content)
		target    = self.target
		reference = target.extract content
		self.update! reference: reference, content: reference, checked_at: Time.now, changed_at: nil, last_error: nil
	end

	def diff!(content, debug: false)
		self.checked_at = Time.now
		state           = :unchanged

		begin
			target    = self.target
			reference = Utils.utf8! self.content
			content   = target.extract content
			changed   = reference != content
			if changed
				puts Utils.diff reference, content if debug
				state           = :changed
				self.content    = content
				self.changed_at = self.checked_at
			end
			self.last_error = nil
		rescue => e
			raise
			$stderr.puts e
			state           = :error
			self.last_error = e
		end

		self.save!
		state
	end

	def recalculate!(debug: false)
		state = :unchanged

		target    = self.target
		reference = self.site.reference
		content   = self.site.content || reference

		reference = target.extract reference
		content   = target.extract content

		changed_at = self.changed_at

		if reference == content
			content    = nil
			changed_at = nil
		else
			puts Utils.diff reference, content if debug
			state      = :changed
			changed_at ||= self.checked_at
		end

		self.update! reference: reference, content: content, changed_at: changed_at

		state
	end

	def clear!
		self.update! reference: nil, content: nil, checked_at: nil, changed_at: nil, last_error: nil
	end
end
