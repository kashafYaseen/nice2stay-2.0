class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string   :name
      t.text     :content
      t.boolean  :disable,        default: true
      t.string   :slug
      t.string   :title
      t.string   :meta_title
      t.text     :villas_desc
      t.text     :apartment_desc
      t.text     :bb_desc
      t.boolean  :dropdown,       default: false
      t.boolean  :sidebar,        default: false

      t.timestamps
    end
  end
end
