class AddMealPriceToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :meal_price, :float, default: 0
  end
end
