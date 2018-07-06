class ChangeImagesColumnTypeInLodgings < ActiveRecord::Migration[5.2]
  def up
    remove_column :lodgings, :images
    add_column :lodgings, :images, :string, array: true
  end

  def down
    remove_column :lodgings, :images
    add_column :lodgings, :images, :json
  end
end
