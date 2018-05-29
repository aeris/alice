class CreateTemplates < ActiveRecord::Migration[5.1]
	def change
		create_table :templates do |t|
			t.string :name, unique: true

			t.index :name, unique: true
		end
	end
end
