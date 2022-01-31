ActiveAdmin.register NewsletterSubscription do
  permit_params :email, :language

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :language
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :language
    end
    f.actions
  end
end
