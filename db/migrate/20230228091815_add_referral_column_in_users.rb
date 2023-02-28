class AddReferralColumnInUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :referral, :integer
  end
end
