ActiveAdmin.register Reservation do
  remove_filter :review, :rules, :prices, :total_price, :discount, :rent, :crm_booking, :cleaning_cost

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      Reservation.includes(:user, { lodging: :translations }).order(created_at: :desc)
    end
  end

  index do
    selectable_column
    id_column
    column :user
    column :lodging
    column :check_in
    column :check_out
    column :booking_status
    column :request_status
    column :rent
    column :created_at
    column :in_cart

    actions
  end
end
