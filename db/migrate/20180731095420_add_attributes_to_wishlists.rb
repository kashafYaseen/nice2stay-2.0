class AddAttributesToWishlists < ActiveRecord::Migration[5.2]
  def change
    add_column :wishlists, :check_in, :date
    add_column :wishlists, :check_out, :date
    add_column :wishlists, :adults, :integer
    add_column :wishlists, :children, :integer
    add_column :wishlists, :name, :string
    add_column :wishlists, :notes, :text
  end
end
