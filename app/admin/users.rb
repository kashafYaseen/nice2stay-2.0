ActiveAdmin.register User do
  remove_filter :reservations, :reviews, :wishlists, :leads, :admin, :image

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :phone
      row :country
      row :address
      row :city
      row :zipcode
      row :created_at
      row :updated_at
    end

    panel "Bookings" do
      table_for user.bookings do
        column :id
        column :identifier do |booking|
          link_to booking.identifier, admin_booking_path(booking)
        end
        column :booking_status
        column :pre_payment
        column :final_payment
        column :in_cart
        column :created_at
      end
    end

    panel "Wishlists" do
      table_for user.wishlists do
        column :id do |wishlist|
          link_to wishlist.id, admin_wishlist_path(wishlist)
        end

        column :lodging
        column :check_in
        column :check_out
        column :adults
        column :in_cart
        column :created_at
      end
    end

    active_admin_comments
  end
end
