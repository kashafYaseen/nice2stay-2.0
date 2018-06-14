ActiveAdmin.register Review do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :stars, :description, :user

  form do |f|
    inputs 'Specification' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :user
      f.input :stars
      f.input :description
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :lodging
      row :user
      row :stars
      row :description
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
