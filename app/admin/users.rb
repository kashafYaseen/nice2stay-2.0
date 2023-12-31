ActiveAdmin.register User do
  filter :email
  filter :first_name
  filter :last_name
  filter :country
  filter :creation_status, as: :select, collection: User.creation_statuses.keys

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
      row :referral
      row :zipcode
      row :creation_status
      row :created_at
      row :updated_at
    end

    panel "First Visit" do
      attributes_table_for user.first_visit do
        row(:landing_page) { |v| link_to(v.landing_page, v.landing_page) if v.landing_page }
        row(:referrer) { |v| link_to(v.referrer, v.referrer) if v.referrer }
        row('Time to Signup') {|v| distance_of_time_in_words(v.user.created_at, v.started_at) }
        row(:location)
        row(:technology)
        row(:utm_source)
        row(:utm_medium)
        row(:utm_term)
        row(:utm_content)
        row(:utm_campaign)
      end
    end

    panel "Upcoming Bookings" do
      table_for user.bookings.upcoming do
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

    panel "Old Bookings" do
      table_for user.bookings.old do
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

    panel "Cart Bookings" do
      table_for user.reservations.in_cart do
        column :id do |reservation|
          link_to reservation.id, admin_reservation_path(reservation)
        end

        column :identifier do |reservation|
          link_to reservation.identifier, admin_booking_path(reservation.booking)
        end

        column :lodging
        column :check_in
        column :check_out
        column :adults
        column :children
        column :created_at
      end
    end

    panel "Trips" do
      table_for user.trips do
        column :id do |trip|
          link_to trip.id, admin_trip_path(trip)
        end

        column :name
        column :visibility
        column :need_advise
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

    panel 'Ahoy Events - Index', class: 'async-panel', 'data-url': ahoy_events_admin_user_path(user)

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

  member_action :ahoy_events do
    @events = resource.events
    render layout: false
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
