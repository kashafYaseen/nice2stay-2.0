class AddRatingAttributesToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :setting, :float, default: 0.0
    add_column :lodgings, :quality, :float, default: 0.0
    add_column :lodgings, :interior, :float, default: 0.0
    add_column :lodgings, :communication, :float, default: 0.0
    add_column :lodgings, :service, :float, default: 0.0
    add_column :lodgings, :average_rating, :float, default: 0.0
  end
end
