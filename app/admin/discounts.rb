ActiveAdmin.register Discount do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :start_date, :end_date, :value, :guests, { minimum_days: [] }

  form do |f|
    inputs 'Rule' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :start_date
      f.input :end_date
      f.input :publish
      f.input :discount_type
      f.input :minimum_days
      f.input :value
      f.input :guests
      f.input :description
      f.input :short_desc
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
      row :minimum_days
      row :discount_type
      row :value
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
