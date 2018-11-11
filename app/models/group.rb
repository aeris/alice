class Group < ApplicationRecord
	belongs_to :template, optional: true
	has_many :sites
	has_many :targets

	validates :name, uniqueness: true

	def self.[](name)
		self.where(name: name).first
	end

	def all_targets
		targets  = self.targets
		template = self.template
		targets  += template.targets if template
		targets
	end
end
