ActiveAdmin.register RoomType do
  config.per_page = 15

  filter :code
  filter :parent_lodging
  permit_params :code, :description, :parent_lodging_id
  actions :show, :index

  index do
    selectable_column
    id_column
    column :code
    column :description
    column :parent_lodging

    actions
  end
end
