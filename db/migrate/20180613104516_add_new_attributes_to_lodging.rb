class AddNewAttributesToLodging < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :title, :string
    add_column :lodgings, :subtitle, :string
    add_column :lodgings, :description, :text
  end
end
