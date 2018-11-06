if ActiveRecord::Base.connection.table_exists? 'custom_text_translations'
  CustomText.includes(:translations).find_each do |custom_text|
    get "#{custom_text.translation_with 'en', 'seo_path'}", to: "lodgings#index", defaults: { locale: :en, custom_text: custom_text.id }
    get "#{custom_text.translation_with 'nl', 'seo_path'}", to: "lodgings#index", defaults: { locale: :nl, custom_text: custom_text.id }
  end
end
