class AddImageToAmenity < ActiveRecord::Migration[5.2]
  def change
    add_column :amenities, :image, :string
  end
end
