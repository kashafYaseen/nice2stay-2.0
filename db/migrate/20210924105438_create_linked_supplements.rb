class CreateLinkedSupplements < ActiveRecord::Migration[5.2]
  def change
    create_table :linked_supplements do |t|
      t.references :supplementable, index: { name: :index_linked_supplements_on_supplementable }, polymorphic: true
      t.references :supplement, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
