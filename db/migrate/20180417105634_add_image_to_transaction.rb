class AddImageToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :image, :string
  end
end
