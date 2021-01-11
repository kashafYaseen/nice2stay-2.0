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
  end

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :price
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    inputs 'RatePlan' do
      f.input :code
      f.input :name
      f.input :price
      f.input :description
    end

    f.actions do
      f.action :submit
    end
  end


  show do
    attributes_table do
      row :code
      row :name
      row :price
      row :description
    end

    active_admin_comments
  end
end
