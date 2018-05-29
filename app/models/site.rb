class Site < ApplicationRecord
	attribute :targets, :targets

	belongs_to :group, optional: true
	belongs_to :template, optional: true
	has_many :targets

	validates :url, presence: true

	def self.grab(url)
		response = HTTParty.get url, timeout: 10.seconds
		raise "Receive #{response.code}" unless response.success?
		response
	end

	def self.html(url)
		response     = self.grab url
		content_type = response.content_type
		raise "Expecting #{'text/html'.colorize :yellow}, got #{content_type.colorize :yellow}" unless content_type == 'text/html'
		content = response.body
		Nokogiri::HTML.parse content
	end

	def self.title(url)
		html = self.html url
		tag  = html.at 'head title'
		tag&.text
	end

	def all_targets
		targets  = self.targets
		group    = self.group
		targets  += groups.targets if group
		template = self.template
		targets  = template.targets if template
		targets
	end

	def check
		self.checked_at = Time.now
		state           = :no_changes
		error           = nil

		begin
			reference = self.reference

			response = self.class.grab self.url
			content  = response.body
			unless reference
				self.reference = content
				state          = :new
			else
				self.content = content
				unchanged    = true

				content_type = response.content_type
				case content_type
				when 'text/html'
					targets = self.targets
					if targets
						targets.each do |target|
							target_content   = target.extract content
							target_reference = target.extract reference
							target_unchanged = target_content == target_reference
							unless target_unchanged
								unchanged = target_unchanged
								break
							end
						end
					else
						unchanged = content == reference
					end
				else
					unchanged = content == reference
				end

				unless unchanged
					self.changed_at = self.checked_at
					state           = :changes
				end
			end
			self.last_error = nil
		rescue => e
			self.last_error = e.to_s
			error           = e
		end

		self.save!
		raise error if error
		state
	end
end
