class AddIcalToLodging < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :ical, :string
  end
end
