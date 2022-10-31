class AddChannelToLodging < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :channel, :integer, default: 0
  end
end
