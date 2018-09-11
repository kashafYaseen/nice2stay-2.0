class AddAttributesImagesAndThumbnails < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :thumbnails, :string, array: true, default: []
    add_column :countries, :thumbnails, :string, array: true, default: []
    add_column :regions, :thumbnails, :string, array: true, default: []
    add_column :campaigns, :thumbnails, :string, array: true, default: []

    add_column :countries, :images, :string, array: true, default: []
    add_column :regions, :images, :string, array: true, default: []
  end
end
