ActiveAdmin.register Specification do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :title, :description

  form do |f|
    inputs 'Specification' do
      f.input :lodging_id, input_html: { disabled: true }
      f.input :title
      f.input :description
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :lodging
      row :title
      row :description
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
