class AddAddressFieldsToVouchers < ActiveRecord::Migration[5.2]
  def change
    add_column :vouchers, :receiver_city, :string
    add_column :vouchers, :receiver_zipcode, :string
    add_column :vouchers, :receiver_address, :string
    add_reference :vouchers, :receiver_country, index: true
    add_foreign_key :vouchers, :countries, column: :receiver_country_id
  end
end
