class AddNewColumnsToLodgings < ActiveRecord::Migration[5.1]
  def change
    add_column :lodgings, :lodging_type, :integer, default: 1
    add_column :lodgings, :adults, :integer, default: 1
    add_column :lodgings, :children, :integer, default: 1
    add_column :lodgings, :infants, :integer, default: 1
  end
end
