class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.references :lodging, index: true
      t.references :user, index: true
      t.integer :stars
      t.text :description

      t.timestamps
    end
    add_foreign_key :reviews, :lodgings, on_indelete: :cascade
    add_foreign_key :reviews, :users, on_indelete: :cascade
  end
end
