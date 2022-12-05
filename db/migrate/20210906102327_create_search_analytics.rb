class CreateSearchAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :search_analytics do |t|
      t.text :params

      t.timestamps
    end
  end
end
