class Template < ApplicationRecord
	has_many :targets
	has_many :sites

	validates :name, uniqueness: true

	def self.[](name)
		self.where(name: name).first
	end
end
