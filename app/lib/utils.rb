module Utils
	def self.diff(a, b, context: 3, limit: 30)
		diff = Diffy::Diff.new a, b, context: context
		diff = diff.to_s :color
		return '...(too much diff)...'.colorize :light_red if diff.lines.size > limit
		diff
	end
end
