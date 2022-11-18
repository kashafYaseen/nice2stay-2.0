class AddColumnCancellationTypeInCancellationPolicies < ActiveRecord::Migration[5.2]
  def change
    add_column :cancellation_policies, :cancellation_type, :integer
  end
end
