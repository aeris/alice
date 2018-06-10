class CreateGroups < ActiveRecord::Migration[5.1]
	def change
		create_table :groups do |t|
			t.string :name, null: false, index: { unique: true }

			t.belongs_to :template, index: true, foreign_key: true
		end
	end
end
