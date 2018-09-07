class CreateAmenities < ActiveRecord::Migration[5.2]
  def change
    create_table :amenities do |t|
      t.string   :name
      t.string   :slug
      t.boolean  :filter_enabled
      t.boolean  :hot

      t.timestamps
    end
  end
end
