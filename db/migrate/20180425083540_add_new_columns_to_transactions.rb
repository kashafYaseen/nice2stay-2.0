class AddNewColumnsToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :transaction_type, :integer, default: 1
    add_column :transactions, :adults, :integer, default: 1
    add_column :transactions, :children, :integer, default: 1
    add_column :transactions, :infants, :integer, default: 1
  end
end
