ActiveAdmin.register Country do
  permit_params :name, :title, :boost

  filter :boost
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
    column :boost
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :title
      f.input :boost
    end
    f.actions
  end
end
