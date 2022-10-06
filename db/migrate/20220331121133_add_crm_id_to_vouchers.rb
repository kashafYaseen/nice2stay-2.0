class AddCrmIdToVouchers < ActiveRecord::Migration[5.2]
  def change
    add_column :vouchers, :crm_id, :integer
  end
end
