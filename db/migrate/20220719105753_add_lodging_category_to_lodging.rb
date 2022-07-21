class AddLodgingCategoryToLodging < ActiveRecord::Migration[5.2]
  def change
    add_reference :lodgings, :lodging_category, index: true
    add_foreign_key :lodgings, :lodging_categories
  end
end
