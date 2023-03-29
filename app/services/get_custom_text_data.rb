class GetCustomTextData
  include Rails.application.routes.url_helpers

  attr_reader :locale

  def self.call(locale)
    self.new(locale).call
  end

  def initialize(locale)
    @locale = locale
  end

  def call
    CustomText.search('*', { load: false }).map { |custom_text| {
      id: custom_text.id,
      h1_text: custom_text.send("h1_text_#{locale}"),
      p_text: custom_text.send("p_text_#{locale}"),
      meta_title: custom_text.send("meta_title_#{locale}"),
      meta_description: custom_text.send("meta_description_#{locale}"),
      category: custom_text.send("category_#{locale}"),
      seo_path: custom_text.send("seo_path_#{locale}"),
      menu_title: custom_text.send("menu_title_#{locale}"),
      experience: custom_text.experience,
      homepage: custom_text.homepage,
      country_page: custom_text.country_page,
      region_page: custom_text.region_page,
      navigation_popular: custom_text.navigation_popular,
      navigation_country: custom_text.navigation_country,
      image: custom_text.image,
      inspiration: custom_text.inspiration,
      popular: custom_text.popular,
      show_page: custom_text.show_page,
      special_offer: custom_text.special_offer,
    }}
  end
end
