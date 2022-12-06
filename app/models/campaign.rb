class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions
  serialize :category, Hash

  include ImageHelper

  URL_MAKER = ["categories", "experiences", "price", "amenities", "guests", "accommodations", "place_categories"]
  MODEL_MAPPING = {'experiences' => 'Experience', 'categories' => 'LodgingCategory', 'amenities' => 'Amenity'}

  searchkick text_middle: [:title_en, :title_nl]

  validates :title, :description, presence: true
  translates :title, :url, :description, :crm_urls
  globalize_accessors

  default_scope { includes(:translations) }
  scope :home_page, -> { where(collection: true, popular_homepage: true) }
  scope :menu, -> { where(slider: true) }
  scope :spotlight, -> { where(popular_homepage: true, spotlight: true) }
  scope :search_import, -> { home_page }

  def should_index?
    popular_homepage
    # collection && popular_homepage
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
      url_en << "country=#{country.try(:slug_en)}"
      url_nl << "country=#{country.try(:slug_nl)}"
    end

    if self.region_id
      region = get_region(self.region_id)
      url_en << "region=#{region.try(:slug_en)}"
      url_nl << "region=#{region.try(:slug_nl)}"
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
      url_en << "starts_from=#{self.from.strftime('%d-%m-%Y')}"
      url_nl << "starts_from=#{self.from.strftime('%d-%m-%Y')}"
    end

    if self.to.present?
      url_en << "ends_on=#{self.to.strftime('%d-%m-%Y')}"
      url_nl << "ends_on=#{self.to.strftime('%d-%m-%Y')}"
    end

    Campaign::URL_MAKER.each do |key|
      next unless self.try(:category) && self.try(:category).keys.any? {|k| k.include? key}

      values = self.try(:category).select{|k, value | k.include?(key)}.values
      data = []

      if MODEL_MAPPING[key].present?
        model_data = MODEL_MAPPING[key].constantize.where(crm_id: values)
        if key == 'categories'
          model_data = model_data.map{|c| {en: c.name_en, nl: c.name_nl}}
        else
          model_data = model_data.map{|c| {en: c.slug_en, nl: c.slug_nl}}
        end
        url_en << "#{key}=#{model_data.map{|k| k[:en]}.join(',')}"
        url_nl << "#{key}=#{model_data.map{|k| k[:nl]}.join(',')}"
      else
        url_en << "#{key}=#{values.join(",")}"
        url_nl << "#{key}=#{values.join(",")}"
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
