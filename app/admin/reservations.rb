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
    column 'Lodging' do |reservation|
      reservation.lodging_wrt_channel
    end

    column :rate_plan
    column :check_in
    column :check_out
    column :booking_status
    column :request_status
    column :rent
    column :created_at
    column :in_cart
    column :channel_manager do |reservation|
      reservation.guest_centric?
    end
    column :user
    column :created_by

    actions
  end

  show do
    attributes_table do
      row :check_in
      row :check_out
      row :created_at
      row :updated_at
      row :adults
      row :children
      row :infants
      row :total_price
      row :rent
      row :discount
      row :cleaning_cost
      row :booking_status
      row :request_status
      row :crm_booking_id
      row :in_cart
      row :lodging
      row :booking
      row :canceled
      row :booked_by
      row :guest_centric_booking_id
      row :offer
      row :meal
      row :meal_price
      row :gc_errors
      row :rooms
      row :meal_tax
      row :tax
      row :additional_fee
      row :room_type
      row :gc_policy
      row :expired_at
      row :book_option
      row :cancel_option_reason
      row :canceled_by
    end

    panel 'Guest Details' do
      table_for reservation.guest_details do
        column :id
        column :name
        column :age
        column :created_at
      end
    end
  end
end
