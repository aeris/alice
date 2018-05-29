class CreateGroups < ActiveRecord::Migration[5.1]
	def change
		create_table :groups do |t|
			t.string :name, null: false, unique: true
			t.string :targets

			t.belongs_to :template, index: true, foreign_key: true

			t.index :name, unique: true
			t.index :template
		end
	end
end
