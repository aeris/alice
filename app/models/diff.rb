class Diff < ApplicationRecord
	belongs_to :site

	def self.dates
		sql = <<-SQL
			SELECT DISTINCT date_trunc('day', created_at) AS date
			FROM #{self.table_name}
			ORDER BY date ASC
		SQL
		ActiveRecord::Base.connection.execute(sql)
			.collect { |r| Date.parse r['date'] }
	end
end
