class AddBoostToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :boost, :integer, default: 0
  end
end
