class AddBeCategoryIdToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :be_category_id, :string
  end
end
