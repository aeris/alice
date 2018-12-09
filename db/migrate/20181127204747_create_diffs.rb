class CreateDiffs < ActiveRecord::Migration[5.2]
	def change
		create_table :diffs do |t|
			t.json :content, null: false

			t.belongs_to :site, index: true, foreign_key: true, null: false
			t.datetime :created_at, null: false
		end
	end
end
