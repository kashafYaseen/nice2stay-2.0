ActiveAdmin.register Rule do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :start_date, :end_date, :minimum_stay, :flexible_arrival

  form do |f|
    inputs 'Rule' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :start_date
      f.input :end_date
      f.input :flexible_arrival
      f.input :minimum_stay
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
      row :minimum_stay
      row :flexible_arrival
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
