class AddCoumnCrmIdInExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :crm_id, :integer
  end
end
