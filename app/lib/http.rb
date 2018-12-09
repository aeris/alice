require 'xz'

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
		html = self.html
		return nil unless html
		tag = html.parse.at 'head title'
		tag&.text
	end

	def charset
		self.html&.charset
	end

	def body
		charset = self.charset
		body    = @response.body
		body    = body.force_encoding charset if charset
		body.encode! 'utf-8' unless body.encoding == Encoding::UTF_8
		body
	end

	protected

	def html
		return nil unless self.html?
		@html ||= Html.new @response.body
	end

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
