class CreateSocialLogins < ActiveRecord::Migration[5.2]
  def change
    create_table :social_logins do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.references :user, index: true

      t.timestamps
    end
    add_foreign_key :social_logins, :users, on_delete: :cascade
  end
end
