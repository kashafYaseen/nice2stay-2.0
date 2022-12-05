class AddOpenGdsAccommodationIdFieldToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :open_gds_accommodation_id, :string
  end
end
