ActiveAdmin.register User do
  remove_filter :reservations, :reviews, :wishlists, :leads, :admin, :image

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :created_at

    actions
  end
end
