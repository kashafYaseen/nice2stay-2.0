class AddConvertOptionToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :book_option, :integer, default: 0
  end
end
