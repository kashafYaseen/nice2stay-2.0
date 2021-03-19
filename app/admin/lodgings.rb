ActiveAdmin.register Lodging do
  config.per_page = 15

  filter :name
  filter :slug
  filter :owner, label: 'Partner'
  filter :country_id_eq, as: :select, collection: Country.all.collect{ |country| [country.name, country.id] }, label: 'Country'
  filter :published
  filter :presentation, as: :select, collection: Lodging.presentations

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def scoped_collection
      return Lodging.includes(:translations) if action_name == "index"

      lodging = Lodging.friendly.find(params[:id])
      return Lodging.includes({ room_rate_availabilities: %i[prices rate_plan] }, { room_rates: :rate_plan }, :discounts, :rules) if lodging.belongs_to_channel?

      Lodging.includes({availabilities: :prices}, :discounts, :rules)
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :name
    column :address
    column :open_gds_property_id
    column :open_gds_accommodation_id
    column :beds
    column :baths
    column :sq__ft
    column :price
    column :total_prices
    column :total_rules
    column :total_children
    column :created_at
    column :updated_at
    column :published
    column :country
    column(:channel) { |lodging| lodging.channel.titleize }

    actions
  end

  remove_filter :reservations, :availabilities, :prices, :rules, :discounts

  form do |f|
    inputs 'Lodging' do
      f.input :owner
      f.input :title
      f.input :subtitle
      f.input :street
      f.input :city
      f.input :zip
      f.input :state
      f.input :beds
      f.input :baths
      f.input :sq__ft
      f.input :sale_date
      f.input :price
      f.input :latitude
      f.input :longitude
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :lodging_type
      f.input(:channel) { |lodging| lodging.channel.titleize }
      f.input :adults
      f.input :children
      f.input :infants
      f.input :description
      f.input :check_in_day, collection: Rule::DAY_OF_WEEK, as: :select
      f.input :flexible_arrival
    end

    f.has_many :specifications, allow_destroy: true, new_record:  'Add Specification'  do |spec|
      spec.input :title
      spec.input :description
    end

    f.has_many :rules, allow_destroy: true, new_record:  'Add Rule'  do |rule|
      rule.input :start_date
      rule.input :end_date
      rule.input :flexible_arrival
      rule.input :minimum_stay
    end

    f.has_many :reviews, allow_destroy: true, new_record:  'Add Review'  do |review|
      review.input :user
      review.input :stars, min: 1, max: 5, step: 1
      review.input :description
    end

    f.has_many :availabilities, allow_destroy: true, new_record:  'Add Availability'  do |availability|
      availability.input :available_on
      availability.input :check_out_only
      availability.has_many :prices, allow_destroy: true, new_record: 'Add Price' do |price|
        price.input :amount
        price.input :adults
        price.input :children
        price.input :infants
      end
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :title
      row :subtitle
      row :owner
      row :street
      row :city
      row :zip
      row :state
      row :beds
      row :baths
      row :sq__ft
      row :sale_date
      row :price
      row :latitude
      row :longitude
      row :description
      row :lodging_type
      row :channel
      row :adults
      row :children
      row :infants
      row :minimum_adults
      row :minimum_children
      row :minimum_infants
      row :total_prices
      row :total_rules
      row :total_children
      row :flexible_arrival
      row :check_in_day
      row :region_page
      row :country_page
      row :home_page
      row :open_gds_property_id
      row :open_gds_accommodation_id
      row :extra_beds
      row :extra_beds_for_children_only
      row :created_at
      row :updated_at
    end

    panel "Cleaning Costs" do
      table_for lodging.cleaning_costs do
        column :crm_id
        column :name
        column :fixed_price
        column :price_per_day
        column :guests
        column :manage_by

        column 'Actions' do |cleaning_cost|
          link_to 'details', admin_cleaning_cost_path(cleaning_cost)
        end
      end
    end

    panel "Rules" do
      table_for lodging.rules.order(:start_date) do
        column :start_date
        column :end_date
        column :minimum_stay
        column :checkin_day
        column :flexible_arrival

        column 'Action' do |rule|
          link_to 'Edit', edit_admin_rule_path(rule)
        end
      end
    end

    panel "Discounts" do
      table_for lodging.discounts do
        column :start_date
        column :end_date
        column :discount_type
        column :minimum_days
        column :value

        column 'Action' do |discount|
          link_to 'Edit', edit_admin_discount_path(discount)
        end
      end
    end

    panel "Reviews" do
      table_for lodging.reviews do
        column :user
        column :stars
        column :description

        column 'Action' do |review|
          link_to 'Edit', edit_admin_review_path(review)
        end
      end
    end

    panel 'Rate Plans' do
      if lodging.as_parent?
        table_for lodging.rate_plans do
          column('Rate Plan Code') { |rate_plan| rate_plan.code }
          column('Rate Plan Name') { |rate_plan| rate_plan.name }
          column('Rate Plan Enabled') { |rate_plan| rate_plan.rate_enabled }
          column('OpenGDS Pushed At') { |rate_plan| rate_plan.opengds_pushed_at }

          column 'Action' do |rate_plan|
            link_to 'View', admin_rate_plan_path(rate_plan)
          end
        end
      else
        table_for lodging.room_rates do
          column :rate_plan_code
          column :rate_plan_name
          column :default_rate
          column :publish
          column :rate_plan_opengds_pushed_at

          column 'Action' do |room_rate|
            link_to 'View', admin_rate_plan_path(room_rate.rate_plan)
          end
        end
      end
    end

    panel "Availabilities" do
      table_for lodging.availabilities_wrt_channel.sort_by(&:available_on) do
        column :id
        column :available_on
        column :check_out_only

        if lodging.belongs_to_channel?
          column :rate_plan
          column 'Availability' do |availability|
            availability.rr_booking_limit
          end

          column 'Check-In Closed' do |availability|
            availability.rr_check_in_closed
          end

          column 'Check-Out Closed' do |availability|
            availability.rr_check_out_closed
          end
        end

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

        column 'Actions' do |availability|
          link_to 'Edit Availability', edit_admin_availability_path(availability)
        end
      end
    end
    active_admin_comments
  end
end
