class CreateLodgingChildren < ActiveRecord::Migration[5.2]
  def change
    create_table :lodging_children do |t|
      t.references :lodging, index: true

      t.timestamps
    end
    add_foreign_key :lodging_children, :lodgings, on_delete: :cascade
  end
end
