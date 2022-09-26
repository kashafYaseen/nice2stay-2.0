class CreateJoinTableVisitedLodging < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :lodgings, table_name: :visited_lodgings do |t|
      t.index [:user_id, :lodging_id]
    end
  end
end
