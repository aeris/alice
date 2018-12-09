class Target < ApplicationRecord
	has_many :templates
	has_many :groups
	has_many :sites

	def to_s
		return self.name if self.name

		s = []
		s << "from: #{self.from}" if self.from
		s << "to: #{self.to}" if self.to
		s << "css: #{self.css}" if self.css
		s.join ' '
	end

	def to_h
		{
				name: self.name,
				from: self.from,
				to:   self.to,
				css:  self.css
		}.compact
	end

	def self.from_h(hash)
		hash.symbolize_keys!
		self.new name: hash[:name], from: hash[:from], to: hash[:from], css: hash[:css]
	end

	def extract_boundary(content)
		return nil unless content
		if self.from
			i = content.index self.from
			unless i
				# $stderr.puts "Unable to find `from` #{self.from}"
				return nil
				raise "Unable to find `from` #{self.from}"
			end
			content = content[i..-1]
		end

		if self.to
			i = content.index self.to
			unless i
				# $stderr.puts "Unable to find `to` #{self.to}"
				return nil
				raise "Unable to find `to` #{self.to}"
			end
			content = content[0..i + self.to.size]
		end
		content
	end

	def extract_css(content)
		return nil unless content
		return content unless self.css
		content = Nokogiri::HTML.parse content
		node    = content.at self.css
		unless node
			# $stderr.puts "Unable to find `css` #{self.css}"
			return nil
			raise "Unable to find `css` #{self.css}"
		end
		node.to_s
	end

	def extract(content)
		return nil unless content
		content = self.extract_boundary content
		content = self.extract_css content
		content
	end

	def diff(reference, content)
		reference = self.extract reference
		content   = self.extract content
		Diffy::Diff.diff reference, content
	end
end
