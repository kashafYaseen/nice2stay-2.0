ActiveAdmin.register Lead do

  permit_params :from, :to, :user_id, :adults, :childrens, country_ids: [:id]

  form do |f|
    inputs 'Lead' do
      f.input :from
      f.input :to
      f.input :adults
      f.input :childrens
      f.input :user
      f.input :countries
    end

    f.actions do
      f.action :submit
    end
  end

  index do
    selectable_column
    id_column
    column :from
    column :to
    column :adults
    column :childrens
    column :user
    column :extra_information
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :from
      row :to
      row :adults
      row :childrens
      row :user
      row :extra_information
      row :created_at
      row :updated_at
    end

    panel "Countries" do
      table_for lead.countries do
        column :name
      end
    end


    active_admin_comments
  end
end
