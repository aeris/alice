module Diffy
	class Diff
		def dump
			self.diff
		end

		def load(diff)
			@diff = diff
			@paths = ['', '']
			self
		end

		def self.load(diff, options = {})
			self.new(nil, nil, options).load diff
		end

		def self.diff(string1, string2)
			return nil if string1 == string2
			Diffy::Diff.new string1, string2, context: 3
		end
	end
end
