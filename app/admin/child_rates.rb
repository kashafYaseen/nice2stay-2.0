ActiveAdmin.register ChildRate do
  permit_params :age_group
  actions :edit, :update, :index

  index do
    selectable_column
    id_column
    column :age_group
    column :open_gds_category
    column :rate
    column :rate_type
    column :rate_plan

    actions
  end

  form do |f|
    inputs 'Child Rate' do
      f.input :age_group
    end

    f.actions do
      f.action :submit
    end
  end
end
