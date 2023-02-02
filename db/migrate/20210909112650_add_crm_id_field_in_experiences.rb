class AddCrmIdFieldInExperiences < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :experiences, :crm_id
      add_column :experiences, :crm_id, :bigint
    end
  end
end
