ActiveAdmin.register Booking do
  controller do
    def permitted_params
      params.permit!
    end
  end

  scope :by_nice2stay, default: true do |booking|
    booking.by_nice2stay
  end

  scope :by_partners do |booking|
    booking.by_partner
  end

  form do |f|
    inputs 'Booking' do
      f.input :booking_status
      f.input :pre_payment
      f.input :final_payment
      f.input :pre_payment_mollie_id
      f.input :final_payment_mollie_id
      f.input :pre_payed_at, as: :date_time_picker
      f.input :final_payed_at, as: :date_time_picker
      f.input :security_payed_at, as: :date_time_picker

      f.input :confirmed
    end

    f.actions do
      f.action :submit
    end
  end

  index do
    selectable_column
    id_column
    column :identifier
    column :booking_status
    column :pre_payment
    column :final_payment
    column :pre_payed_at
    column :final_payed_at
    column :security_payed_at
    column :confirmed
    column :in_cart
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :identifier
      row :booking_status
      row :pre_payment
      row :final_payment
      row :in_cart
      row :confirmed
      row :pre_payed_at
      row :final_payed_at
      row :pre_payment_mollie_id
      row :final_payment_mollie_id
      row :created_at
      row :updated_at

      row :customer_name do |booking|
        booking.user_full_name
      end

      row :customer_email do |booking|
        booking.user_email
      end

      row :customer_phone do |booking|
        booking.user_phone
      end

      row :customer_city do |booking|
        booking.user_city
      end

      row :customer_zipcode do |booking|
        booking.user_zipcode
      end

      row :customer_country do |booking|
        booking.user_country_name
      end
    end

    panel "Reservations" do
      table_for booking.reservations do
        column :id do |reservation|
          link_to reservation.id, admin_reservation_path(reservation)
        end
        column :lodging
        column :check_in
        column :check_out
        column :adults
        column :children
        column :created_at
      end
    end
  end
end
