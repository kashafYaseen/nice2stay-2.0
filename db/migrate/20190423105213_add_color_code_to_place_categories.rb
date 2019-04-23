class AddColorCodeToPlaceCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :place_categories, :color_code, :string, default: '#7D3C98'
    remove_column :places, :publish, :string
    add_column :places, :publish, :boolean, default: true
  end
end
