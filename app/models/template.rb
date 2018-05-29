class Template < ApplicationRecord
	attribute :targets, :targets

	has_many :targets

	validates :name, uniqueness: true

	def self.[](name)
		self.where(name: name).first
	end
end
