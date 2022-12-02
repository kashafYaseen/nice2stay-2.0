class AddColumnCrmIdInAmenities < ActiveRecord::Migration[5.2]
  def change
    add_column :amenities, :crm_id, :integer
  end
end
