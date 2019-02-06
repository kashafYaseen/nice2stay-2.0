class UpdateDiscountsSchema < ActiveRecord::Migration[5.2]
  def change
    add_column :discounts, :description, :string
    add_column :discounts, :short_desc, :string
    add_column :discounts, :publish, :boolean, default: false
    add_column :discounts, :discount_type, :string, default: "percentage"
    add_column :discounts, :valid_to, :datetime
    add_column :discounts, :minimum_days, :integer, default: [], array: true
    add_column :discounts, :value, :integer
    add_column :discounts, :crm_id, :integer
    add_column :discounts, :guests, :integer

    remove_column :discounts, :reservation_days, :integer
    remove_column :discounts, :discount_percentage, :float
  end
end
