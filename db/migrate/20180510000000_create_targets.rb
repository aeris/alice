class CreateTargets < ActiveRecord::Migration[5.1]
  def change
    create_table :targets do |t|
      t.belongs_to :template, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true
      t.belongs_to :site, index: true, foreign_key: true

      t.timestamps
    end
  end
end
