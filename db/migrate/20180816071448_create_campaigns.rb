class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :slug
      t.string :url
      t.string :article_spotlight
      t.text :publish, default: [], array: true
      t.text :images, default: [], array: true
      t.text :description
      t.text :slider_desc
      t.integer :price
      t.boolean :slider
      t.boolean :spotlight
      t.boolean :popular_search
      t.boolean :popular_homepage
      t.boolean :collection

      t.timestamps
    end
  end
end
