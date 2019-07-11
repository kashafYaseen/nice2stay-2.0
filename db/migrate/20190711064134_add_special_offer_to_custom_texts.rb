class AddSpecialOfferToCustomTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :special_offer, :boolean, default: false
  end
end
