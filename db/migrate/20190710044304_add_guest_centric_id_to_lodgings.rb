class AddGuestCentricIdToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :guest_centric_id, :string
    add_column :lodgings, :guest_centric, :boolean, default: false
  end
end
