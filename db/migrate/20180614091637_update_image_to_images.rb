class UpdateImageToImages < ActiveRecord::Migration[5.2]
  def change
    remove_column :lodgings, :image, :string
    add_column    :lodgings, :images, :json
  end
end
