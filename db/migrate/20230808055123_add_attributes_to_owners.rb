class AddAttributesToOwners < ActiveRecord::Migration[5.2]
  def up
    add_column :owners, :business_name, :string
    add_column :owners, :account_id, :integer
    add_column :owners, :email_boolean, :boolean, default: false
    add_column :owners, :not_interested, :boolean, default: false
    add_column :owners, :language, :string
    add_column :owners, :updating_availability, :boolean, default: false
    add_column :owners, :automated_availability, :boolean, default: false
  end

  def down
    remove_column :owners, :business_name
    remove_column :owners, :account_id
    remove_column :owners, :email_boolean
    remove_column :owners, :not_interested
    remove_column :owners, :language
    remove_column :owners, :updating_availability
    remove_column :owners, :automated_availability
  end
end
