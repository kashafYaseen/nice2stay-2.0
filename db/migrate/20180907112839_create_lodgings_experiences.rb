class CreateLodgingsExperiences < ActiveRecord::Migration[5.2]
  def change
    create_table :lodgings_experiences do |t|
      t.references :lodging, index: true
      t.references :experience, index: true
    end
    add_foreign_key :lodgings_experiences, :lodgings, on_delete: :cascade
    add_foreign_key :lodgings_experiences, :experiences, on_delete: :cascade
  end
end
