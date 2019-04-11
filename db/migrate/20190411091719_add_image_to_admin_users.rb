class AddImageToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :image, :string
    add_column :admin_users, :first_name, :string
    add_column :admin_users, :last_name, :string
    add_reference :owners, :admin_user, index: true
    add_foreign_key :owners, :admin_users
  end
end
