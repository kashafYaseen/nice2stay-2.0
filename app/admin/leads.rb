ActiveAdmin.register Lead do
  permit_params :from, :to, :user_id, :adults, :childrens, country_ids: [:id]

  actions :all, except: [:destroy]

  form do |f|
    inputs 'Lead' do
      f.input :from
      f.input :to
      f.input :adults
      f.input :childrens
      f.input :user
      f.input :countries

      f.has_many :offers, allow_destroy: true, heading: 'Offer', new_record: 'Add New Offer' do |offer|
        offer.input :from
        offer.input :to
        offer.input :adults
        offer.input :childrens

        offer.has_many :offer_lodgings, allow_destroy: true, new_record: 'Add Accommodation' do |offer_lodging|
          offer_lodging.input :lodging
        end
      end
    end

    f.actions do
      f.action :submit
    end
  end

  index do
    selectable_column
    id_column
    column :from
    column :to
    column :adults
    column :childrens
    column :default_status
    column :user
    column :extra_information
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :from
      row :to
      row :adults
      row :childrens
      row :default_status
      row :user
      row :extra_information
      row :created_at
      row :updated_at
    end

    panel "Countries" do
      table_for lead.countries do
        column :name
      end
    end


    active_admin_comments
  end
end
