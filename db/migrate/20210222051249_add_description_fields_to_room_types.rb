class AddDescriptionFieldsToRoomTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :room_types, :baths, :integer
    add_column :room_types, :short_description, :string
    add_column :room_types, :images, :string, array: true, default: []
    add_column :room_types, :num_of_accommodations, :integer, default: 1
    add_column :room_types, :minimum_adults, :integer, default: 1
    add_column :room_types, :minimum_children, :integer, default: 0
    add_column :room_types, :minimum_infants, :integer, default: 0
  end
end
