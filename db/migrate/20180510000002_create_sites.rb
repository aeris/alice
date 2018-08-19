class CreateSites < ActiveRecord::Migration[5.1]
	def change
		create_table :sites do |t|
			t.string :url, null: false
			t.string :name, index: true

			t.text :reference
			t.text :content

			t.belongs_to :group, index: true, foreign_key: true
			t.belongs_to :template, index: true, foreign_key: true

			t.string :last_error
			t.datetime :checked_at
			t.datetime :changed_at
		end
	end
end
