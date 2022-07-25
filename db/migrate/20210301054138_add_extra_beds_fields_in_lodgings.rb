class AddExtraBedsFieldsInLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :extra_beds, :integer, default: 0
    add_column :lodgings, :extra_beds_for_children_only, :boolean, default: false
  end
end
