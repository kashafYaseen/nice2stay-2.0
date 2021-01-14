ActiveAdmin.register RoomType do
  config.per_page = 15

  filter :code
  filter :parent_lodging
  permit_params :code, :description, :parent_lodging_id
  actions :show, :index


  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      return RoomType.includes(parent_lodging: :translations) if action_name == 'index'

      RoomType.includes(room_rates: :rate_plan, availabilities: [:rate_plan, :prices, { cleaning_costs: :translations }])
    end
  end

  index do
    selectable_column
    id_column
    column :code
    column :description
    column :parent_lodging

    actions
  end


  show do
    attributes_table do
      row :code
      row :description
      row :parent_lodging
    end

    panel "Rate Plans" do
      table_for room_type.room_rates do
        column :rate_plan_code
        column :rate_plan_name
        column :default_rate
        column 'Action' do |room_rate|
          link_to 'Edit', edit_admin_rate_plan_path(room_rate.rate_plan)
        end
      end
    end

    panel "Availabilities" do
      table_for room_type.availabilities.sort_by(&:available_on) do
        column :id
        column :available_on
        column 'Booking Limit', :rr_booking_limit
        column 'Check-in Closed', :rr_check_in_closed
        column 'Check-out Closed', :rr_check_out_closed
        column :rate_plan

        column 'Prices' do |availability|
          table_for availability.prices do
            column :amount
            column :adults
            column :children
            column :infants
            column :minimum_stay
            column :checkin

            column 'Action' do |price|
              link_to 'Edit Price', edit_admin_price_path(price)
            end
          end
        end

        column 'Cleaning Costs' do |availability|
          table_for availability.cleaning_costs do
            column :name
            column :fixed_price

            column 'Action' do |cleaning_cost|
              link_to 'Edit Cleaning Cost', edit_admin_cleaning_cost_path(cleaning_cost)
            end
          end
        end

        column 'Actions' do |availability|
          link_to 'Edit Availability', edit_admin_availability_path(availability)
        end
      end
    end

    active_admin_comments
  end
end
