ActiveAdmin.register RatePlan do
  config.per_page = 15

  filter :code
  filter :room_type
  permit_params :code, :name, :room_type
  actions :show, :index, :edit, :update


  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      return RatePlan.all if action_name == 'index'

      RatePlan.includes(:child_rates, :rule, room_rates: :room_type)
    end
  end

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :open_gds_rate_id
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    inputs 'RatePlan' do
      f.input :code
      f.input :name
      f.input :description
      f.input :open_gds_rate_id
      f.inputs do
        f.has_many :room_rates, heading: 'Linked Room Types', allow_destroy: true, new_record: 'Link Another Room Type' do |rr_form|
          rr_form.input :room_type
          rr_form.input :default_rate
        end
      end
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :code
      row :name
      row('OpenGDS Rate ID') { |rate_plan| rate_plan.open_gds_rate_id }
      row :description
      row :rate_enabled
      row('Permanent Valid') { |rate_plan| rate_plan.open_gds_valid_permanent }
      row :min_stay
      row :max_stay
      row :open_gds_rate_type
      row :open_gds_daily_supplements
    end

    panel 'Rule' do
      table_for rate_plan.rule do
        column :start_date
        column :end_date
        column :open_gds_restriction_type
        column :open_gds_restriction_days
        column :open_gds_arrival_days
      end
    end

    panel 'Room Types' do
      table_for rate_plan.room_rates do
        column :room_type_code
        column :room_type_name
        column :open_gds_accommodation_id
        column :default_rate
        column 'Action' do |room_rate|
          link_to 'View', admin_room_type_path(room_rate.room_type)
        end
      end
    end

    panel 'Child Rates' do
      table_for rate_plan.child_rates do
        column :children
        column :rate_type
        column :rate
      end
    end

    active_admin_comments
  end
end
