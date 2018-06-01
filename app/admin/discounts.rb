ActiveAdmin.register Discount do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :start_date, :end_date, :reservation_days, :discount_percentage

  form do |f|
    inputs 'Rule' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :start_date
      f.input :end_date
      f.input :reservation_days, min: 1, step: 1
      f.input :discount_percentage
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
      row :reservation_days
      row :discount_percentage
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
