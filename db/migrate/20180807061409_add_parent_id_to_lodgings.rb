class AddParentIdToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_reference :lodgings, :parent, index: true
  end
end
