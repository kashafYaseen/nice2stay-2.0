class AddCreatedByToVouchers < ActiveRecord::Migration[5.2]
  def change
    add_column :vouchers, :created_by, :integer, default: 0
  end
end
