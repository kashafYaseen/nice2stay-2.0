ActiveAdmin.register Price do
  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    inputs 'Price' do
      f.input :availability_id, as: :select, label: 'Availability', collection: Availability.ids
      f.input :amount
      f.input :adults
      f.input :children
      f.input :infants
    end

    f.actions do
      f.action :submit
    end
  end
end
