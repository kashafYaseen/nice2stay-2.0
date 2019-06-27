class AddBoostToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :boost, :integer, default: 0
  end
end
