class AddOptimizeAtToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :optimize_at, :datetime
  end
end
