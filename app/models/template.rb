class Template < ApplicationRecord
	has_many :targets, dependent: :delete_all
	has_many :sites, dependent: :delete_all

	validates :name, uniqueness: true
	accepts_nested_attributes_for :targets, allow_destroy: true, reject_if: lambda{ |a| a[:name].blank? }

	def self.[](name)
		self.where(name: name).first
	end
end
