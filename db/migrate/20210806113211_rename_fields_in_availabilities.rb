class RenameFieldsInAvailabilities < ActiveRecord::Migration[5.2]
  def change
    rename_column :availabilities, :rr_minimum_stay, :minimum_stay
    rename_column :availabilities, :rr_check_in_closed, :check_in_closed
    rename_column :availabilities, :rr_check_out_closed, :check_out_closed
    rename_column :availabilities, :rr_booking_limit, :booking_limit
  end
end
