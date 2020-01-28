ActiveAdmin.register Trip do
  actions :index, :show

  index do
    selectable_column
    id_column
    column :name
    column :user do |trip|
      trip.trip_members.first.try(:user)
    end

    column :accommodations do |trip|
      trip.wishlists.count
    end

    column :visibility
    column :need_advise
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :name
      row :check_in
      row :check_out
      row :visibility
      row :adults
      row :children
      row :budget
      row :need_advise
      row :created_at
      row :updated_at
    end

    panel "Accommodations" do
      table_for trip.wishlists do
        column :lodging
      end
    end

    panel "Members" do
      table_for trip.trip_members do
        column :user
      end
    end

    active_admin_comments
  end
end
