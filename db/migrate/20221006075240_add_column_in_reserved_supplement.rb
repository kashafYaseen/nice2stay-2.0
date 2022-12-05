class AddColumnInReservedSupplement < ActiveRecord::Migration[5.2]
  def change
    add_column :reserved_supplements, :quantity, :integer, default: 0
  end
end
