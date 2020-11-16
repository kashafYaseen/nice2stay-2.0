class AddRatePlanReferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :availabilities, :rate_plan, foreign_key: { on_delete: :cascade }
    add_reference :cleaning_costs, :rate_plan, foreign_key: { on_delete: :cascade }
  end
end
