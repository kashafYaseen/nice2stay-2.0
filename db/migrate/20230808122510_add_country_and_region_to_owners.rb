class AddCountryAndRegionToOwners < ActiveRecord::Migration[5.2]
  def up
    add_reference :owners, :country, foreign_key: true
    add_reference :owners, :region, foreign_key: true
  end

  def down
    remove_reference :owners, :country, foreign_key: true
    remove_reference :owners, :region, foreign_key: true
  end
end
