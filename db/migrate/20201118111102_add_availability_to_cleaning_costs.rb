class AddAvailabilityToCleaningCosts < ActiveRecord::Migration[5.2]
  def change
    add_reference :cleaning_costs, :availability, foreign_key: { on_delete: :cascade }
  end
end
