class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.datetime :read_at
      t.string :action
      t.integer :notifiable_id
      t.string :notifiable_type

      t.timestamps
    end
    add_foreign_key :notifications, :users, on_delete: :cascade
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end
end
