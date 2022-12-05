class AddNumOfAccommodationsFieldToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :num_of_accommodations, :integer, default: 1
  end
end
