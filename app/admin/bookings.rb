ActiveAdmin.register Booking do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    id_column
    column :identifier
    column :booking_status
    column :pre_payment
    column :final_payment
    column :pre_paid_at
    column :final_paid_at
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
      row :pre_paid_at
      row :final_paid_at
      row :created_at
      row :updated_at
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
