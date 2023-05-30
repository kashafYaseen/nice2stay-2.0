class AddParentToAmenities < ActiveRecord::Migration[5.2]
  def change
    add_column :amenities, :parent, :boolean, default: false
  end
end
