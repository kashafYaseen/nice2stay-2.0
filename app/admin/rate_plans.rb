ActiveAdmin.register RatePlan do
  config.per_page = 15

  filter :parent_lodging
  actions :show, :index, :edit, :update, :new, :create


  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      return RatePlan.all if action_name == 'index'

      RatePlan.includes(:child_rates, :rule, room_rates: %i[child_lodging parent_lodging])
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :parent_lodging
    column :open_gds_rate_id
    column :created_at
    column :updated_at
    column :opengds_pushed_at

    actions
  end

  form do |f|
    inputs 'RatePlan' do
      f.input :parent_lodging
      f.input :name
      f.input :description
      f.input :open_gds_rate_id
      f.inputs do
        f.has_many :room_rates, heading: 'Linked Accommodations', allow_destroy: true, new_record: 'Link Another Accommodation' do |rr_form|
          rr_form.input :child_lodging
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
      row :name
      row('OpenGDS Rate ID') { |rate_plan| rate_plan.open_gds_rate_id }
      row :description
      row :rate_enabled
      row('Permanent Valid') { |rate_plan| rate_plan.open_gds_valid_permanent }
      row :min_stay
      row :max_stay
      row :open_gds_rate_type
      row :open_gds_daily_supplements
      row :opengds_pushed_at
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

    panel 'Lodgings' do
      table_for rate_plan.room_rates do
        column('Room Rate ID') { | room_rate| room_rate.id }
        column :child_lodging
        column :open_gds_accommodation_id
        column :default_rate
        column :parent_lodging
        column :publish
        column :created_at
        column :updated_at
      end
    end

    panel 'Child Rates' do
      table_for rate_plan.child_rates do
        column :age_group
        column :open_gds_category
        column :rate
        column :rate_type
        column 'Action' do |child_rate|
          link_to 'Edit', edit_admin_child_rate_path(child_rate)
        end
      end
    end

    active_admin_comments
  end
end
