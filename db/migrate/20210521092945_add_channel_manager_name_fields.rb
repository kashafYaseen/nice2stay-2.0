class AddChannelManagerNameFields < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :name_on_cm, :string
    add_column :rate_plans, :name_on_cm, :string
  end
end
