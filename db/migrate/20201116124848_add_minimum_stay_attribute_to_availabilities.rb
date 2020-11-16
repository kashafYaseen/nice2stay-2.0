class AddMinimumStayAttributeToAvailabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :availabilities, :minimum_stay, :string, array: true, default: []
  end
end
