ActiveAdmin.register Reservation do
  remove_filter :review, :rules, :prices, :total_price, :discount, :rent, :crm_booking, :cleaning_cost

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      Reservation.requests.includes({ lodging: :translations, booking: :user }).order(created_at: :desc)
    end
  end

  index do
    selectable_column
    id_column
    column :lodging
    column :check_in
    column :check_out
    column :booking_status
    column :request_status
    column :rent
    column :created_at
    column :in_cart
    column :user

    actions
  end
end
