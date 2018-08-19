class CreateChecks < ActiveRecord::Migration[5.1]
	def change
		create_table :checks do |t|
			t.text :reference
			t.text :content

			t.belongs_to :target, index: true, foreign_key: true
			t.belongs_to :site, index: true, foreign_key: true

			t.string :last_error
			t.datetime :checked_at
			t.datetime :changed_at
		end
	end
end
