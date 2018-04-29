class AddImageToLodgings < ActiveRecord::Migration[5.1]
  def change
    add_column :lodgings, :image, :string
  end
end
