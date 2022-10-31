class AddRrFieldsToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :rr_errors, :text
    add_column :reservations, :rr_res_id_value, :integer
  end
end
