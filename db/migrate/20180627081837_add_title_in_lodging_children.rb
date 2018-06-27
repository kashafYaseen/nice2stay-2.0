class AddTitleInLodgingChildren < ActiveRecord::Migration[5.2]
  def change
    add_column :lodging_children, :title, :string
  end
end
