ActiveAdmin.register Price do
  menu false
  actions :all, except: [:index, :new, :create]
  permit_params :amount, :adults, :children, :infants

  form do |f|
    inputs 'Price' do
      f.input :availability_id, input_html: { disabled: true }
      f.input :amount
      f.input :adults
      f.input :children
      f.input :infants
    end

    f.actions do
      f.action :submit
    end
  end

  show do
    attributes_table do
      row :availability
      row :lodging
      row :amount
      row :adults
      row :children
      row :infants
      row :minimum_stay
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
