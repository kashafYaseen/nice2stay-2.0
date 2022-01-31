class AddNameFieldInNewsletterSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_subscriptions, :name, :string
  end
end
