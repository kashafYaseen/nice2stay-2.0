class CreateVouchers < ActiveRecord::Migration[5.2]
  def change
    create_table :vouchers do |t|
      t.string :sender_name
      t.string :sender_email
      t.integer :amount
      t.date :expired_at
      t.boolean :send_by_post, default: false
      t.text :message
      t.references :receiver, foreign_key: { on_delete: :cascade, to_table: :users }

      t.timestamps
    end
  end
end
