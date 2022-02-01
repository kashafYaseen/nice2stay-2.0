class ChangeColumnNameInGuestDetails < ActiveRecord::Migration[5.2]
  def change
    rename_column :guest_details, :type, :guest_type
  end
end
