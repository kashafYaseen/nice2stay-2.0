class AddPresentationToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :presentation, :integer, default: 1
  end
end
