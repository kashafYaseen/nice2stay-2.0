ActiveAdmin.register Meal do
  permit_params :gc_meal_id, :description_en, :description_nl, :name_en, :name_nl

  form do |f|
    f.inputs do
      f.input :gc_meal_id
      f.input :name_en
      f.input :name_nl
      f.input :description_en
      f.input :description_nl
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :gc_meal_id
    column :name_en
    column :name_nl
    column :description_en
    column :description_nl
    actions
  end

  show do
    attributes_table do
      row :gc_meal_id
      row :name_en
      row :name_nl
      row :description_en
      row :description_nl
      row :created_at
      row :updated_at
    end
  end
end
