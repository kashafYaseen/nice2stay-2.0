ActiveAdmin.register Availability do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :available_on, :rr_booking_limit, prices_attributes: [:id, :amount, :adults, :children, :infants, :_destroy]

  form do |f|
    inputs 'Availability' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :available_on
      f.input :rr_booking_limit, label: 'Booking Limit'
    end

    f.has_many :prices, allow_destroy: true, new_record: 'Add Price' do |price|
      price.input :amount
      price.input :adults
      price.input :children
      price.input :infants
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :lodging
      row :available_on
      row 'Booking Limit' do |availability|
        availability.rr_booking_limit
      end

      row :created_at
      row :updated_at
    end

    panel "Prices" do
      table_for availability.prices do
        column :amount
        column :adults
        column :children
        column :infants

        column 'Action' do |price|
          link_to 'Edit Price', edit_admin_price_path(price)
        end
      end
    end
    active_admin_comments
  end
end
