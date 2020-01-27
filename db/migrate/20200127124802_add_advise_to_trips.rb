class AddAdviseToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :need_advise, :boolean, default: false
  end
end
