class AddUniqIndexToAvailabilityOn < ActiveRecord::Migration[5.2]
  def change
    add_index :availabilities, [:lodging_id, :available_on], unique: true
  end
end
