class AddUniquenessConstraintToRegion < ActiveRecord::Migration[5.2]
  def up
    # Add a unique index on country_id and name columns
    add_index :regions, [:country_id, :name], unique: true
  end

  def down
    # Remove the unique index on country_id and name columns
    remove_index :regions, [:country_id, :name]
  end
end
