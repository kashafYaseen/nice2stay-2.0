class AddPreAndFinalPaymentToOwners < ActiveRecord::Migration[5.2]
  def change
    add_column :owners, :pre_payment, :integer, default: 30
    add_column :owners, :final_payment, :integer, default: 70
  end
end
