class Check < ApplicationRecord
	belongs_to :site
	belongs_to :target

	def to_s
		self.target.to_s
	end

	def changed?(reference, content, debug: false)
		target    = self.target
		reference = target.extract reference
		content   = target.extract content
		changed   = reference != content

		if changed
			puts Utils.diff reference, content if debug
			return true
		end

		false
	end

	def diff(reference, content, context: 3, **kwargs)
		target    = self.target
		reference = target.extract reference
		content   = target.extract content
		Diffy::Diff.new reference, content, context: context, **kwargs
	end
end
