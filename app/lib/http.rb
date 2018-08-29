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

	DATE_FORMAT = '%Y%m%d_%H%M%S'.freeze

	def cache(response)
		return unless ENV['DEBUG_HTTP']

		prefix = Digest::SHA256.hexdigest @url
		dir    = File.join Rails.root, 'tmp', 'cache', 'http'
		FileUtils.mkdir_p dirs unless Dir.exist? dir

		body = response.body
		last = Dir[File.join dir, "#{prefix}_*"].sort.last
		if last
			old = Digest::SHA256.file(last).hexdigest
			new = Digest::SHA256.hexdigest body
			return if old == new
		end

		time = Time.now.strftime DATE_FORMAT
		file = prefix + '_' + time
		file = File.join dir, file
		File.binwrite file, body
	end

	def grab
		response = HTTParty.get @url, timeout: 10.seconds
		raise "Receive #{response.code}" unless response.success?
		self.cache response
		response
	end

	def parse
		return nil unless self.html?
		body = @response.body
		Nokogiri::HTML.parse body
	end
end
