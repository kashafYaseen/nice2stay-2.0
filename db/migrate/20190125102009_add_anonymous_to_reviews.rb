class AddAnonymousToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :anonymous, :boolean, default: false
  end
end
