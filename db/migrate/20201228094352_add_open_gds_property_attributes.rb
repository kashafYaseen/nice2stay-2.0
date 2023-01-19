class AddOpenGdsPropertyAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :open_gds_property_id, :integer
    # add_column :room_types, :open_gds_accommodation_id, :integer
    add_column :rate_plans, :open_gds_rate_id, :integer
  end
end
