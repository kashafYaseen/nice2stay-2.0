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
    column :title
    column :name
    column :address
    column :beds
    column :baths
    column :sq__ft
    column :price
    column :total_prices
    column :total_rules
    column :total_children

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
      f.input :adults
      f.input :children
      f.input :infants
      f.input :description
    end

    f.has_many :specifications, allow_destroy: true, new_record:  'Add Specification'  do |spec|
      spec.input :title
      spec.input :description
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

    f.has_many :reviews, allow_destroy: true, new_record:  'Add Review'  do |review|
      review.input :user
      review.input :stars, min: 1, max: 5, step: 1
      review.input :description
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
      row :images do
        ul do
          lodging.images.each do |image|
            li do
              image_tag(image)
            end
          end
        end
      end
      row :lodging_type
      row :adults
      row :children
      row :infants
      row :total_prices
      row :total_rules
      row :total_children
      row :created_at
      row :updated_at
    end

    panel "Specifications" do
      table_for lodging.specifications do
        column :title
        column :description

        column 'Action' do |specification|
          link_to 'Edit', edit_admin_specification_path(specification)
        end
      end
    end

    panel "Rules" do
      table_for lodging.rules do
        column :start_date
        column :end_date
        column :days_multiplier
        column :check_in_days
        column :minimal_stay

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
            column :minimum_stay

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
