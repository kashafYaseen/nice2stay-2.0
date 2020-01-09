class AddGcPolicyToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :gc_policy, :text
  end
end
