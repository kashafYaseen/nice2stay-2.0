class AddOpenGdsAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :rate_enabled, :boolean, default: false
    add_column :rate_plans, :open_gds_valid_permanent, :boolean, default: false
    add_column :rate_plans, :open_gds_res_fee, :decimal, default: 0
    add_column :rate_plans, :open_gds_rate_type, :integer

    add_column :rules, :open_gds_restriction_type, :integer
    add_column :rules, :open_gds_restriction_days, :integer, default: 0
    add_column :rules, :open_gds_arrival_days, :string, array: true, default: []
    add_reference :rules, :rate_plan, foreign_key: { on_delete: :cascade }

    add_column :prices, :open_gds_single_rate_type, :integer, default: 0
    add_column :prices, :open_gds_single_rate, :decimal, default: 0
    add_column :prices, :open_gds_extra_night_rate, :decimal, default: 0
  end
end
