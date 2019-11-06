ActiveAdmin.register Lead do
  actions :all, except: [:destroy]

  action_item :toggle_sidebar, only: [:new, :edit] do
    link_to 'Toggle Sidebar', '#', class: 'toggle-sidebar'
  end

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      scoped_collection.includes(offers: { lodgings: :translations }).find(params[:id])
    end
  end

  form do |f|
    panel "lodgings", class: 'lodgings-panel' do
      render "lodgings"
    end

    inputs 'Lead' do
      f.input :admin_user
      f.input :default_status
      f.input :from
      f.input :to
      f.input :adults
      f.input :childrens
      f.input :user
      f.input :countries

      f.has_many :offers, allow_destroy: true, heading: 'Offer', new_record: 'Add New Offer' do |offer|
        offer.input :title
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

    panel "Offers" do
      table_for lead.offers do
        column :title
        column :from
        column :to
        column :adults
        column :childrens

        column 'Lodgings' do |offer|
          table_for offer.lodgings do
            column :id
            column :name do |lodging|
              link_to lodging.name, admin_lodging_path(lodging)
            end
          end
        end
      end
    end

    active_admin_comments
  end
end
