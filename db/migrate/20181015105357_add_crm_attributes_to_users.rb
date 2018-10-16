class AddCrmAttributesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :zipcode, :string
    add_column :users, :phone, :string
    add_column :users, :language, :string
    add_reference :users, :country, index: true
    add_foreign_key :users, :countries
  end
end
