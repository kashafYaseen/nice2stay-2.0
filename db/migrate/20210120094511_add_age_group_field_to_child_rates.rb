class AddAgeGroupFieldToChildRates < ActiveRecord::Migration[5.2]
  def change
    add_column :child_rates, :age_group, :integer
  end
end
