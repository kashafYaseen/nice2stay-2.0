class AddTokenExpiresAtToOwners < ActiveRecord::Migration[5.2]
  def up
    add_column :owners, :token_expires_at, :string
  end

  def down
    remove_column :owners, :token_expires_at
  end
end
