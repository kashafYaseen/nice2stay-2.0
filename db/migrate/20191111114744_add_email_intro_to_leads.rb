class AddEmailIntroToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :email_intro, :text
  end
end
