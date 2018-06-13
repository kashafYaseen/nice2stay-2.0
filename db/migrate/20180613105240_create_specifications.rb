class CreateSpecifications < ActiveRecord::Migration[5.2]
  def change
    create_table :specifications do |t|
      t.references :lodging, index: true
      t.string :title
      t.text :description

      t.timestamps
    end
    add_foreign_key :specifications, :lodgings, on_indelete: :cascade
  end
end
