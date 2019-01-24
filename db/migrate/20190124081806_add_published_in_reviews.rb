class AddPublishedInReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :published, :boolean, default: false
    add_column :reviews, :perfect, :boolean, default: false
  end
end
