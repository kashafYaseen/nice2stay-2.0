class Api::V2::CustomTextSerializer
  include FastJsonapi::ObjectSerializer
  attributes  :id, :experience, :homepage, :country_page, :region_page, :navigation_popular,
              :navigation_country, :image, :inspiration, :popular, :show_page, :special_offer

  attribute :h1_text, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("h1_text_#{params[:locale]}")
  end

  attribute :p_text, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("p_text_#{params[:locale]}")
  end

  attribute :meta_title, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("meta_title_#{params[:locale]}")
  end

  attribute :meta_description, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("meta_description_#{params[:locale]}")
  end

  attribute :category, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("category_#{params[:locale]}")
  end

  attribute :seo_path, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("seo_path_#{params[:locale]}")
  end

  attribute :menu_title, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("menu_title_#{params[:locale]}")
  end

  attribute :url, if: Proc.new { |custom_text, params| params.present? && params[:locale].present? } do |custom_text, params|
    custom_text.send("redirect_url_#{params[:locale]}")
  end
end
