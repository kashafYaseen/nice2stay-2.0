class AddTokenExpiresAtToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :token_expires_at, :string
  end

  def down
    remove_column :admin_users, :token_expires_at
  end
end
