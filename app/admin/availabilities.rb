ActiveAdmin.register Availability do
  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    inputs 'Availability' do
      f.input :lodging_id, as: :select, label: 'Lodging', collection: Lodging.ids
      f.input :available_on
    end

    f.actions do
      f.action :submit
    end
  end
end
