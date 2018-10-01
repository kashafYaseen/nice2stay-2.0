ActiveAdmin.register Wishlist do
  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      Wishlist.includes(:user, { lodging: :translations })
    end
  end

  index do
    selectable_column
    id_column
    column :user
    column :lodging
    column :check_in
    column :check_out
    column :adults
    column :children
    column :status

    actions
  end
end
