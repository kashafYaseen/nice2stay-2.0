class AddCrmIdFieldInExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :crm_id, :bigint
  end
end
