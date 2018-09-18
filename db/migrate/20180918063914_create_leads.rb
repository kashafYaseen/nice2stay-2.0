class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.date     :from
      t.date     :to
      t.text     :extra_information
      t.string   :slug
      t.integer  :status, default: 0
      t.integer  :generated, default: 0
      t.integer  :lead_type, default: 0
      t.integer  :default_status, default: 0
      t.integer  :adults, default: 1
      t.integer  :childrens, default: 0
      t.string   :created_by
      t.text     :notes
      t.datetime :offer_date
      t.string   :preferred_country
      t.string   :preferred_accommodations
      t.string   :potential
      t.text     :offer_text
      t.boolean  :publish, default: false
      t.references :user, index: true

      t.timestamps
    end
    add_foreign_key :leads, :users, on_delete: :cascade
  end
end
