ActiveAdmin.register Page do
  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  form do |f|
    inputs 'Page' do
      f.input :category
      f.input :header_dropdown
      f.input :rating_box
      f.input :homepage
      f.input :title
      f.input :meta_title
      f.input :short_desc
      f.input :content
    end

    f.actions do
      f.action :submit
    end
  end
end
