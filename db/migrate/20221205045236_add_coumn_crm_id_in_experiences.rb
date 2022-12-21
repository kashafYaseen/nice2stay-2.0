class AddCoumnCrmIdInExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :crm_id, :integer unless Experience.column_names.include?("crm_id")
  end
end
