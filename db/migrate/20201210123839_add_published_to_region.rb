class AddPublishedToRegion < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :published, :boolean, default: false
  end
end
