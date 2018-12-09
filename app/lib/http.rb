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

	DATE_FORMAT = '%Y%m%d_%H%M%S'.freeze

	def self.prefix(url)
		Digest::SHA256.hexdigest url
	end

	HTTP_CACHE_DIR = File.join Rails.root, 'tmp', 'cache', 'http'
	FileUtils.mkdir_p HTTP_CACHE_DIR unless Dir.exist? HTTP_CACHE_DIR

	def cache(response)
		return unless ENV['DEBUG_HTTP']

		prefix = self.class.prefix @url

		body = response.body
		last = Dir[File.join dir, "#{prefix}_*"].sort.last
		if last
			old = Digest::SHA256.file(last).hexdigest
			new = Digest::SHA256.hexdigest body
			return if old == new
		end

		time = Time.now.strftime DATE_FORMAT
		file = prefix + '_' + time + '.xz'
		file = File.join dir, file
		body = XZ.compress body, level: 9
		File.binwrite file, body
	end

	def self.cache(file)
		body = File.binread file
		XZ.decompress body
	end

	def self.caches(url)
		prefix        = self.prefix url
		Dir["#{HTTP_CACHE_DIR}/#{prefix}_*.xz"]
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
