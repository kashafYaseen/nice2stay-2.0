ActiveAdmin.register Rule do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :start_date, :end_date, :days_multiplier, :check_in_days

  form do |f|
    inputs 'Rule' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :start_date
      f.input :end_date
      f.input :days_multiplier, min: 1, step: 1
      f.input :check_in_days, collection: Rule::DAY_OF_WEEK, as: :select
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :lodging
      row :start_date
      row :end_date
      row :days_multiplier
      row :check_in_days
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
