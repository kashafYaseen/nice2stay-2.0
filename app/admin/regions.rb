ActiveAdmin.register Region do
  permit_params :name, :country_id, :title

  filter :name
  filter :title
  filter :created_at

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :title
    column :accommodations do |country|
      country.lodgings.count
    end
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :title
      f.input :country
    end
    f.actions
  end
end
