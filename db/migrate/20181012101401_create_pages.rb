class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string   :title
      t.string   :meta_title
      t.text     :short_desc
      t.text     :content
      t.string   :category
      t.string   :slug
      t.boolean  :header_dropdown, default: false
      t.boolean  :rating_box, default: false
      t.boolean  :homepage, default: false
      t.string   :images, array: true, default: []

      t.timestamps
    end
  end
end
