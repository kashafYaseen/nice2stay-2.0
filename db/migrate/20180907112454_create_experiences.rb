class CreateExperiences < ActiveRecord::Migration[5.2]
  def change
    create_table :experiences do |t|
      t.string   :name
      t.string   :tag
      t.string   :slug
      t.text     :short_desc
      t.boolean  :publish

      t.timestamps
    end
  end
end
