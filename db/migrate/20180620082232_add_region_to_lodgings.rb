class AddRegionToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_reference :lodgings, :region, index: true
    add_foreign_key :lodgings, :regions, on_delete: :cascade
  end
end
