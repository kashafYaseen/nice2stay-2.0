class AddCrmAttributesToLodgings < ActiveRecord::Migration[5.2]
  def change
    change_table :lodgings do |t|
      t.column :slug, :string
      t.column :name, :string
      t.column :meta_title, :string
      t.column :h1, :string
      t.column :h2, :string
      t.column :h3, :string
      t.column :highlight_1, :string
      t.column :highlight_2, :string
      t.column :highlight_3, :string
      t.column :label, :string
      t.column :summary, :text
      t.column :location_description, :text
      t.column :meta_desc, :text
      t.column :short_desc, :text
      t.column :published, :boolean, default: false
      t.column :heads, :boolean, default: false
      t.column :confirmed_price, :boolean, default: false
      t.column :include_cleaning, :boolean, default: false
      t.column :include_deposit, :boolean, default: false
      t.column :checked, :boolean, default: false
      t.column :flexible, :boolean, default: false
      t.column :listed_to, :boolean, default: false
      t.column :ical_validated, :boolean, default: false
      t.column :route_updated_at, :datetime
      t.column :price_updated_at, :datetime
      t.column :status, :integer
    end
  end
end
