ActiveAdmin.register Lodging do
  config.per_page = 15

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      return Lodging.all if action_name == "index"
      Lodging.includes({availabilities: :prices}, :discounts, :rules)
    end
  end

  index do
    selectable_column
    id_column
    column :address
    column :beds
    column :baths
    column :sq__ft
    column :price

    actions
  end

  remove_filter :reservations, :availabilities, :prices, :rules, :discounts

  form do |f|
    inputs 'Lodging' do
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
      f.input :image, as: :file
      f.input :lodging_type
      f.input :adults
      f.input :children
      f.input :infants
    end

    f.has_many :rules, allow_destroy: true, new_record:  'Add Rule'  do |rule|
      rule.input :start_date
      rule.input :end_date
      rule.input :days_multiplier, min: 1, step: 1
      rule.input :check_in_days, collection: Rule::DAY_OF_WEEK, as: :select
    end

    f.has_many :discounts, allow_destroy: true, new_record:  'Add Discount'  do |discount|
      discount.input :start_date
      discount.input :end_date
      discount.input :reservation_days, min: 1, step: 1
      discount.input :discount_percentage
    end

    f.has_many :availabilities, allow_destroy: true, new_record:  'Add Availability'  do |availability|
      availability.input :available_on
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
      row :image, as: :file
      row :lodging_type
      row :adults
      row :children
      row :infants
      row :created_at
      row :updated_at
    end

    panel "Rules" do
      table_for lodging.rules do
        column :start_date
        column :end_date
        column :days_multiplier
        column :check_in_days

        column 'Action' do |rule|
          link_to 'Edit', edit_admin_rule_path(rule)
        end
      end
    end

    panel "Discounts" do
      table_for lodging.discounts do
        column :start_date
        column :end_date
        column :reservation_days
        column :discount_percentage

        column 'Action' do |discount|
          link_to 'Edit', edit_admin_discount_path(discount)
        end
      end
    end

    panel "Availabilities" do
      table_for lodging.availabilities do
        column :id
        column :available_on

        column 'Prices' do |availability|
          table_for availability.prices do
            column :amount
            column :adults
            column :children
            column :infants

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