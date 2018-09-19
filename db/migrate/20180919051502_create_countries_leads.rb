class CreateCountriesLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :countries_leads do |t|
      t.references :lead, index: true
      t.references :country, index: true

      t.timestamps
    end
    add_foreign_key :countries_leads, :leads, on_delete: :cascade
    add_foreign_key :countries_leads, :countries, on_delete: :cascade
  end
end
