class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions
  serialize :category, Hash

  include ImageHelper

  URL_MAKER = ["categories", "experiences", "amenities", "guests"]
  MODEL_MAPPING = {'experiences' => 'Experience', 'categories' => 'LodgingCategory', 'amenities' => 'Amenity'}
  ULR_KEYS = {'experiences' => 'experiences_in[]', 'categories' => 'types_in[]', 'amenities' => 'amenities_in[]', 'guests' => 'adults'}

  searchkick text_middle: [:title_en, :title_nl]

  # validates :title, :description, presence: true
  validates :title, presence: true
  translates :title, :url, :description, :crm_urls
  globalize_accessors

  default_scope { includes(:translations) }
  scope :home_page, -> { where(collection: true, popular_homepage: true) }
  scope :menu, -> { where(slider: true) }
  scope :spotlight, -> { where(popular_homepage: true, spotlight: true) }
  scope :search_import, -> { home_page }

  def should_index?
    collection || popular_homepage || popular_search || footer || top_menu
  end

  def search_data
    url_en, url_nl = redirect_url
    attributes.merge(
      title_en: title_en,
      title_nl: title_nl,
      regions: regions.collect(&:name),
      redirect_url_en: url_en,
      redirect_url_nl: url_nl
    )
  end

  def redirect_url
    url_en = []
    url_nl = []

    if self.country_id
      country = get_country(self.country_id)
      url_en << "countries_in=#{country.try(:slug_en)}"
      url_nl << "countries_in=#{country.try(:slug_nl)}"
    end

    if self.region_id
      region = get_region(self.region_id)
      url_en << "regions_in=#{region.try(:slug_en)}"
      url_nl << "regions_in=#{region.try(:slug_nl)}"
    end

    if self.min_price.present?
      url_en << "min_price=#{self.min_price.round}"
      url_nl << "min_price=#{self.min_price.round}"
    end

    if self.max_price.present?
      url_en << "max_price=#{self.max_price.round}"
      url_nl << "max_price=#{self.max_price.round}"
    end

    if self.from.present?
      url_en << "check_in=#{self.from.strftime('%Y-%m-%d')}"
      url_nl << "check_in=#{self.from.strftime('%Y-%m-%d')}"
    end

    if self.to.present?
      url_en << "check_out=#{self.to.strftime('%Y-%m-%d')}"
      url_nl << "check_out=#{self.to.strftime('%Y-%m-%d')}"
    end

    Campaign::URL_MAKER.each do |key|
      next unless self.try(:category) && self.try(:category).keys.any? {|k| k.include? key}

      values = self.try(:category).select{|k, value | k.include?(key)}.values
      url_key = ULR_KEYS[key]

      if MODEL_MAPPING[key].present?
        model_data = MODEL_MAPPING[key].constantize.where(crm_id: values)
        model_data = key == 'categories' ? model_data.map{|c| {en: c.name_en, nl: c.name_nl}} : model_data.map{|c| {en: c.slug_en, nl: c.slug_nl}}
        url_en << model_data.map{|k| "#{url_key}=#{k[:en]}"}.join('&')
        url_nl << model_data.map{|k| "#{url_key}=#{k[:nl]}"}.join('&')
      else
        url_en << "#{url_key}=#{values.join}"
        url_nl << "#{url_key}=#{values.join}"
      end
    end
    ["?#{url_en.join("&")}", "?#{url_nl.join("&")}"]
  end

  def get_country(id)
    Country.find_by(crm_id: id)
  end

  def get_region(id)
    Region.find_by(crm_id: id)
  end
end
