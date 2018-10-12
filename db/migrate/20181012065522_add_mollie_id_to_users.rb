class AddMollieIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mollie_id, :string
  end
end
