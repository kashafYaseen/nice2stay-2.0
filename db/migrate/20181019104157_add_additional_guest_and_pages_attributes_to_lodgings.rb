class AddAdditionalGuestAndPagesAttributesToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :minimum_adults, :integer, default: 1
    add_column :lodgings, :minimum_children, :integer, default: 0
    add_column :lodgings, :minimum_infants, :integer, default: 0

    add_column :lodgings, :home_page, :boolean, default: false
    add_column :lodgings, :region_page, :boolean, default: false
    add_column :lodgings, :country_page, :boolean, default: false
  end
end
