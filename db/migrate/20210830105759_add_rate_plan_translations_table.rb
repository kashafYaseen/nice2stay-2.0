class AddRatePlanTranslationsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_plan_translations do |t|
      t.string :locale
      t.string :name
      t.text :description
      t.references :rate_plan, index: true
    end

    add_foreign_key :rate_plan_translations, :rate_plans, on_delete: :cascade
  end
end
