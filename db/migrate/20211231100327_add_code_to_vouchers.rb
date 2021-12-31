class AddCodeToVouchers < ActiveRecord::Migration[5.2]
  def change
    add_column :vouchers, :code, :string
    add_column :vouchers, :used, :boolean, default: false
    remove_column :vouchers, :expired_at, :date
    add_column :vouchers, :expired_at, :datetime
  end
end
