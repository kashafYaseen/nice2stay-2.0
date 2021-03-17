ActiveAdmin.register Reservation, as: "Cart" do
  actions :show, :index

  filter :lodging
  filter :check_in
  filter :check_out
  filter :adults
  filter :children
  filter :infants
  filter :created_at

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      Reservation.in_cart.includes({ lodging: :translations, booking: :user }).order(created_at: :desc)
    end
  end

  index do
    selectable_column
    id_column
    column :lodging
    column 'Expired' do |reservation|
      reservation.expired? ? 'Yes' : 'No'
    end
    column :user
    column :check_in
    column :check_out
    column :rent
    column :created_at
  end
end
