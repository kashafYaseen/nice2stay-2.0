class AddOpenGdsAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :open_gds_property_id, :integer
    add_column :lodgings, :open_gds_accomodation_id, :integer
    add_column :prices, :open_gds_rate_id, :integer
  end
end
