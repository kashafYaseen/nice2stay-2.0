ActiveAdmin.register User do
  filter :email
  filter :first_name
  filter :last_name
  filter :country

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
    column :creation_status

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
      row :creation_status
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

    panel "Social Logins" do
      table_for user.social_logins do
        column :uid
        column :provider
        column :email
        column :created_at
        column :confirmed_at
      end
    end

    active_admin_comments
  end

  action_item :send_invitation, only: [:show, :edit] do
    link_to 'Edit Password', edit_password_admin_user_path
  end

  member_action :edit_password do
  end

  member_action :update_password, method: :patch do
    if resource.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      redirect_to admin_user_path(resource), notice: 'Password was updated successfully'
    else
      render :edit_password
    end
  end

  form do |f|
    f.object.skip_validations = true
    inputs 'Rule' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
      f.input :city
      f.input :country
      f.input :zipcode
      f.input :confirmed_at
      f.input :skip_validations, as: :hidden
    end

    f.actions do
      f.action :submit
    end
  end
end
