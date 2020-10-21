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


  show do
    attributes_table do
      row :code
      row :description
      row :parent_lodging
    end

    panel "Rooms" do
      table_for room_type.child_lodgings do
        column :owner
        column :title
        column :subtitle
        column :street
        column :city
        column :zip
        column :state
        column :lodging_type
        column :description

        column 'Actions' do |lodging|
          link_to 'View', admin_lodging_path(lodging)
        end
      end
    end

    active_admin_comments
  end
end
