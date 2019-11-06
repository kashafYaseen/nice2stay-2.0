class AddTitleToOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :offers, :title, :string
    add_reference :leads, :admin_user, index: true
    add_foreign_key :leads, :admin_users
  end
end
