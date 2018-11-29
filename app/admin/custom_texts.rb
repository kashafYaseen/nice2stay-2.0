ActiveAdmin.register CustomText do
  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      CustomText.includes(:translations, :country, :region, :experience)
    end
  end

  index do
    selectable_column
    id_column
    column :translations do |custom_text|
      custom_text.translations.count
    end

    column :seo_path
    column :country
    column :region
    column :experience
    column :home_page
    column :country_page
    column :region_page
    column :navigation_popular
    column :navigation_country

    actions
  end
end
