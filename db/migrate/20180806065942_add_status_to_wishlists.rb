class AddStatusToWishlists < ActiveRecord::Migration[5.2]
  def change
    add_column :wishlists, :status, :integer, default: 0
  end
end
