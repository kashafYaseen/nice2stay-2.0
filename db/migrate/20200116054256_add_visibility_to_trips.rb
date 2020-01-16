class AddVisibilityToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :visibility, :integer, default: 0
  end
end
