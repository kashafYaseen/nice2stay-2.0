class AddedOpenGdsFieldsInReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :open_gds_res_id, :string
    add_column :reservations, :open_gds_error_name, :string
    add_column :reservations, :open_gds_error_message, :string
    add_column :reservations, :open_gds_error_code, :integer
    add_column :reservations, :open_gds_error_status, :integer
  end
end
