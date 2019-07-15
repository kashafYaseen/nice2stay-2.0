class AddConfirmationToSocialLogins < ActiveRecord::Migration[5.2]
  def change
    add_column :social_logins, :confirmation_token, :string
    add_column :social_logins, :confirmed_at, :datetime
    add_column :social_logins, :confirmation_sent_at, :datetime
    add_index :social_logins, :confirmation_token, unique: true
  end
end
