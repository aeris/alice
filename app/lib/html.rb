class Html
	def initialize(content)
		@content = content
		charset = self.charset
		@content.force_encoding charset if charset
	end

	def title
		html = self.parse
		return nil unless html
		tag = html.at 'head title'
		tag&.text
	end

	def to_s
		@content
	end

	def self.to_s(content)
		self.new(content).to_s
	end

	def parse
		@parse ||= Nokogiri::HTML.parse @content
	end

	def charset
		html = self.parse

		# Content-Type charset seems already processed by HTTParty
		# charset = @response.headers['content-type']
		# charset = /text\/html;\s*charset=(.*)/i.match charset
		# return charset[1] if charset

		charset = html.at 'head meta[charset]'
		return charset['charset'] if charset

		charset = html.at 'head meta[http-equiv="Content-Type"]'
		if charset
			charset = charset['content']
			charset = /text\/html;\s*charset=(.*)/i.match charset
			return charset[1] if charset
		end

		nil
	end
end
