class DropTableLodgingChildren < ActiveRecord::Migration[5.2]
  def change
    drop_table :lodging_children do |t|
      t.references :lodging, index: true
      t.string :title

      t.timestamps
    end
  end
end
