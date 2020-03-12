class AddFreeCancelationToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :free_cancelation, :boolean, default: false
  end
end
