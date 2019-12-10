class AddIconToAmenities < ActiveRecord::Migration[5.2]
  def change
    add_column :amenities, :icon, :string
  end
end
