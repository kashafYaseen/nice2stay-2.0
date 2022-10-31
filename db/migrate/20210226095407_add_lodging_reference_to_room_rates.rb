class AddLodgingReferenceToRoomRates < ActiveRecord::Migration[5.2]
  def change
    # add_reference :room_rates, :lodging, foreign_key: { on_delete: :cascade }
    add_reference :room_rates, :child_lodging, index: true
    add_foreign_key :room_rates, :lodgings, on_delete: :cascade, column: :child_lodging_id
  end
end
