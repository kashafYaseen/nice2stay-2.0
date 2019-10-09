class CreateOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :offers do |t|
      t.date     :from
      t.date     :to
      t.integer  :adults, default: 1
      t.integer  :childrens, default: 0
      t.text     :notes
      t.references :lead, index: true

      t.timestamps
    end
    add_foreign_key :offers, :leads, on_delete: :cascade
  end
end
