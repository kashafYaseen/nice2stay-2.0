ActiveAdmin.register Voucher do
  includes :receiver, :receiver_country

  index do
    selectable_column
    id_column

    column :sender_name
    column :sender_email
    column :amount
    column :message

    column 'Receiver Name' do |voucher|
      voucher.receiver.full_name
    end

    column 'Receiver Email' do |voucher|
      voucher.receiver.email
    end

    column :receiver_city
    column :receiver_zipcode
    column :receiver_address
    column :receiver_country
    column :code
    column :used
    column :expired_at
    column :payment_status
    column :payed_at
    column :created_by
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :sender_name
      row :sender_email
      row :amount
      row :message

      row 'Receiver Name' do |voucher|
        voucher.receiver.full_name
      end

      row 'Receiver Email' do |voucher|
        voucher.receiver.email
      end

      row :receiver_city
      row :receiver_zipcode
      row :receiver_address
      row :receiver_country
      row :code
      row :used
      row :expired_at
      row :payment_status
      row :payed_at
      row :created_by
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  csv do
    column :id
    column :sender_name
    column :sender_email
    column :amount
    column :message

    column 'Receiver Name' do |voucher|
      voucher.receiver.full_name
    end

    column 'Receiver Email' do |voucher|
      voucher.receiver.email
    end

    column :receiver_city
    column :receiver_zipcode
    column :receiver_address

    column 'Receiver Country' do |voucher|
      voucher.receiver_country.name
    end

    column :code
    column :used
    column :expired_at
    column :payment_status
    column :payed_at
    column :created_by
    column :created_at
    column :updated_at
  end
end
