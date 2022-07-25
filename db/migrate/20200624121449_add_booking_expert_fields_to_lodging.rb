class AddBookingExpertFieldsToLodging < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :be_category_id, :string
    add_column :lodgings, :be_admin_id, :string
    add_column :lodgings, :be_org_id, :string
    add_column :lodgings, :booking_expert, :boolean, default: :false
  end
end
