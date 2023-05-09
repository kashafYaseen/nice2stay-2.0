ActiveAdmin.register Lead do
  actions :all, except: [:destroy]

  action_item :toggle_sidebar, only: [:new, :edit] do
    link_to 'Toggle Sidebar', '#', class: 'toggle-sidebar'
  end

  action_item :send_offer_email, only: [:show] do
    link_to 'Send Offer Email', send_offer_admin_lead_path(lead), method: :post if lead.offers.present?
  end

  member_action :send_offer, method: :post do
    if resource.offers.present?
      LeadMailer.send_offers(resource.user_id, resource.id).deliver_later
      redirect_to admin_lead_path(resource), notice: "Offer was send successfully."
    else
      redirect_to admin_lead_path(resource), alert: "Lead does not have any offer"
    end
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
      f.input :email_intro_en, as: :text, input_html: { rows: 4 }
      f.input :email_intro_nl, as: :text, input_html: { rows: 4 }

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
      row :email_intro_en
      row :email_intro_nl
      row :url do |lead|
        lead_url(lead)
      end
      row :created_at
      row :updated_at
      row :stay
      row :budget
      row 'preferred_months' do |lead|
        months_array = JSON.parse(lead.preferred_months)
        capitalized_months = months_array.map { |month| month.capitalize }
      end
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
