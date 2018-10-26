if ActiveRecord::Base.connection.table_exists? 'custom_text_translations'
  CustomText.find_each do |custom_text|
    get "en/#{custom_text.seo_path('en')}", to: "lodgings#index", defaults: { locale: :en, custom_text: custom_text.id }
    get "nl/#{custom_text.seo_path('nl')}", to: "lodgings#index", defaults: { locale: :nl, custom_text: custom_text.id }
  end
end
