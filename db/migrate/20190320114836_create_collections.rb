class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.references :parent, index: true
      t.references :relative, index: true

      t.timestamps
    end
    add_foreign_key :collections, :custom_texts, on_delete: :cascade, column: :parent_id
    add_foreign_key :collections, :custom_texts, on_delete: :cascade, column: :relative_id
  end
end
