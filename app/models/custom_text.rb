class CustomText < ApplicationRecord
  belongs_to :country, optional: true
  belongs_to :region, optional: true
  belongs_to :experience, optional: true

  has_many :collections, foreign_key: 'parent_id'
  has_many :relatives, through: :collections

  searchkick

  translates :h1_text, :p_text, :meta_title, :meta_description, :category, :seo_path, :menu_title

  delegate :slug, to: :country, prefix: true, allow_nil: true
  delegate :slug, to: :region, prefix: true, allow_nil: true
  delegate :slug, to: :experience, prefix: true, allow_nil: true

  globalize_accessors

  default_scope { includes(:translations) }
  scope :home_page, -> { where(homepage: true) }
  scope :popular, -> { where(popular: true) }
  scope :inspiration, -> { where(inspiration: true) }
  scope :menu, -> { where(navigation_popular: true) }
  scope :country_menu, -> { where(navigation_country: true) }
  scope :country_page, -> { where(country_page: true) }
  scope :region_page, -> { where(region_page: true) }

  def search_data
    url_en, url_nl = redirect_url
    attributes.merge(
      meta_title_en: meta_title_en,
      meta_title_nl: meta_title_nl,
      meta_description_en: meta_description_en,
      meta_description_nl: meta_description_nl,
      h1_text_en: h1_text_en,
      h1_text_nl: h1_text_nl,
      p_text_en: p_text_en,
      p_text_nl: p_text_nl,
      category_en: category_en,
      category_nl: category_nl,
      seo_path_en: seo_path_en,
      seo_path_nl: seo_path_nl,
      menu_title_en: menu_title_en,
      menu_title_nl: menu_title_nl,
      redirect_url_en: url_en,
      redirect_url_nl: url_nl,
    )
  end

  def translation_with locale, method
    Globalize.with_locale(locale) do
      return send(method)
    end
  end

  def filters
    {
      experiences: { slug: experience_slug, id: experience_id },
      country: { slug: country_slug, id: country_id },
      region: { slug: region_slug, id: region_id },
      lodging_type: { slug: lodging_type(category) },
      discounts: special_offer?,
    }
  end

  def lodging_type(type)
    return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
    return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
    return 'bnb' if ["boutique-hotels", "boutique-hotels", "bnb"].include?(type)
  end

  def redirect_url
    url_en = []
    url_nl = []

    if self.country_id
      country = Country.find(self.country_id)
      url_en << "countries_in[]=#{country.try(:slug_en)}"
      url_nl << "countries_in[]=#{country.try(:slug_nl)}"
    end

    if self.region_id
      region = Region.find(self.region_id)
      url_en << "regions_in[]=#{region.try(:slug_en)}"
      url_nl << "regions_in[]=#{region.try(:slug_nl)}"
    end

    if self.experience_id
      experience = Experience.find(self.experience_id)
      url_en << "experiences_in[]=#{experience.try(:slug_en)}"
      url_nl << "experiences_in[]=#{experience.try(:slug_nl)}"
    end

    if self.category
      url_en << "types_in[]=#{try(:category_en)}"
      url_nl << "types_in[]=#{try(:category_nl)}"
    end

    ["?#{url_en.join("&")}", "?#{url_nl.join("&")}"]
  end
end
