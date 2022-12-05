class CreateCancellationPolicies < ActiveRecord::Migration[5.2]
  def change
    create_table :cancellation_policies do |t|
      t.integer :cancellation_percentage
      t.integer :days_prior_to_check_in
      t.integer :crm_id
      t.references :rate_plan, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
