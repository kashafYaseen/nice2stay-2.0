class AddAttributesToGcOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :gc_offers, :policy, :text
    add_column :gc_offers, :restrictions, :text

    add_column :gc_offer_translations, :policy, :text
    add_column :gc_offer_translations, :restrictions, :text
  end
end
