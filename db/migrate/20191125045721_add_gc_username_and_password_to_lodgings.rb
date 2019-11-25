class AddGcUsernameAndPasswordToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :gc_username, :string
    add_column :lodgings, :gc_password, :string
  end
end
