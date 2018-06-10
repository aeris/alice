module Utils
	def self.utf8!(text)
		return nil unless text
		return text if text.encoding == Encoding::UTF_8
		text.force_encoding 'utf-8'
	end

	def self.diff(a, b, context: 3, limit: 30)
		a = self.utf8! a
		b = self.utf8! b
		diff = Diffy::Diff.new a, b, context: context
		diff = diff.to_s :color
		return '...(too much diff)...'.colorize :light_red if diff.lines.size > limit
		diff
	end
end
