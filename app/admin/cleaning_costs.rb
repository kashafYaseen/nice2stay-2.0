ActiveAdmin.register CleaningCost do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :name, :fixed_price, :price_per_day, :guests, :manage_by

  form do |f|
    inputs 'Price' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :crm_id, input_html: { disabled: true }
      f.input :name
      f.input :fixed_price
      f.input :price_per_day
      f.input :guests
      f.input :manage_by
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :lodging
      row :crm_id
      row :name
      row :fixed_price
      row :price_per_day
      row :guests
      row :manage_by
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
