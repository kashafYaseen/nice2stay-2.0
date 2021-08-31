ActiveAdmin.register Owner do
  actions :all, except: [:new, :destroy, :edit]

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :created_at

    column :pre_payment do |owner|
      "#{owner.pre_payment}%"
    end

    column :final_payment do |owner|
      "#{owner.final_payment}%"
    end

    column :admin_user

    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email

      row :pre_payment do |owner|
        "#{owner.pre_payment}%"
      end

      row :final_payment do |owner|
        "#{owner.final_payment}%"
      end

      row :sign_in_count
      row :created_at
      row :updated_at
      row :admin_user
      row :reset_password_sent_at
      row :current_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
    end
  end
end
