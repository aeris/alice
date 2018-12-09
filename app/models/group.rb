class Group < ApplicationRecord
	belongs_to :template, optional: true
	has_many :sites, dependent: :delete_all
	has_many :targets, dependent: :delete_all

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
