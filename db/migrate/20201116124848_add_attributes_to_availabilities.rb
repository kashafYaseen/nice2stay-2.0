class AddAttributesToAvailabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :availabilities, :rr_minimum_stay, :string, array: true, default: []
    add_column :availabilities, :rr_check_in_closed, :boolean, default: false
    add_column :availabilities, :rr_check_out_closed, :boolean, default: false
    add_column :availabilities, :rr_booking_limit, :integer, default: 0
  end
end
