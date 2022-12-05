class AddParentLodgingReferenceToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :rate_plans, :parent_lodging, index: true
    add_foreign_key :rate_plans, :lodgings, on_delete: :cascade, column: :parent_lodging_id
  end
end
