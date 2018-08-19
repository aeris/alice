class Http
	def initialize(url)
		@url      = url
		@response = self.grab
	end

	def code
		@response.code
	end

	def success?
		@response.success?
	end

	def html?
		@response.content_type == 'text/html'
	end

	def title
		html = self.parse
		return nil unless html
		tag = html.at 'head title'
		tag&.text
	end

	def charset
		return nil unless self.html?

		body = @response.body
		html = Nokogiri::HTML.parse body

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

	def body
		charset = self.charset
		body    = @response.body
		body    = body.force_encoding charset if charset
		body.encode! 'utf-8' unless body.encoding == Encoding::UTF_8
		body
	end

	protected

	def grab
		response = HTTParty.get @url, timeout: 10.seconds
		raise "Receive #{response.code}" unless response.success?
		response
	end

	def parse
		return nil unless self.html?
		body = @response.body
		Nokogiri::HTML.parse body
	end
end
