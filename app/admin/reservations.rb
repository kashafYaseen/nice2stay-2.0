ActiveAdmin.register Reservation do
  actions :show, :index

  scope :requests, default: true
  scope :option

  filter :lodging
  filter :booking_created_by, as: :select, collection: proc { Booking.created_bies }
  filter :check_in
  filter :check_out
  filter :adults
  filter :children
  filter :infants
  filter :in_cart
  filter :canceled
  filter :created_at

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      Reservation.includes({ lodging: :translations, booking: :user }).order(created_at: :desc)
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
    column :created_by

    actions
  end
end
