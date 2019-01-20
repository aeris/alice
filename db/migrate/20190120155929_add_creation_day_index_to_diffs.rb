class AddCreationDayIndexToDiffs < ActiveRecord::Migration[5.2]
	def up
		add_index :diffs, "date_trunc('day', created_at) DESC", name: "diffs_creation_day_index"
	end

	def down
		remove_index :diffs, name: "diffs_creation_day_index"
	end
end
