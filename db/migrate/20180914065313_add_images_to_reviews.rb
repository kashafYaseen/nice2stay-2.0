class AddImagesToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :thumbnails, :string, array: true, default: []
    add_column :reviews, :images, :string, array: true, default: []
  end
end
