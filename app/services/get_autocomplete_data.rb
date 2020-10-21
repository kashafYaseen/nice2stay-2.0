class GetAutocompleteData
  include Rails.application.routes.url_helpers

  attr_reader :params
  attr_reader :locale

  def self.call(params, locale)
    self.new(params, locale).call
  end

  def initialize(params, locale)
    @params = params
    @locale = locale
  end

  def call
    return lodgings if params[:type] == 'lodgings'
    return campaigns if params[:type] == 'campaigns'
    return countries if params[:type] == 'countries'
    return regions if params[:type] == 'regions'
    return themes if params[:type] == 'themes'
    return hotels if params[:type] == 'hotels'
  end

  private
    def lodgings
      Lodging.search(params[:query], {
        fields: [:name],
        match: :text_middle,
        limit: 6,
        load: false,
        misspellings: {below: 5},
        where: { presentation: ['as_parent', 'as_standalone'], published: true }
      }).map{ |lodging| { name: lodging.name, type: 'lodging', id: lodging.id, url: lodging_path(lodging.slug, locale: locale) } }
    end

    def campaigns
      Campaign.search(params[:query], {
        fields: ["title_#{locale}"],
        match: :text_middle,
        limit: 15,
        load: false,
        misspellings: {below: 5},
        where: { collection: true, popular_homepage: true }
      }).map{ |campaign| { name: campaign.send("title_#{locale}"), id: campaign.id, type: 'campaign', url: campaign.url } }
    end

    def countries
      Country.search(params[:query], {
        fields: ["name_#{locale}"],
        match: :text_middle,
        limit: 10,
        load: false,
        misspellings: {below: 5},
        where: { disable: false }
      }).map{ |country| { name: country.send("name_#{locale}"), id: country.id, type: 'country', country: country.slug, lodging_count: country.lodging_count, url: lodgings_path(locale: locale) } }
    end

    def regions
      Region.search(params[:query], {
        fields: ["name_#{locale}"],
        match: :text_middle,
        limit: 10,
        load: false,
        misspellings: {below: 5},
        where: { disable: false }
      }).map{ |region| { name: region.send("name_#{locale}"), id: region.id, type: 'region', country: region.country_slug, country_slug: region.country_slug, country_name: region.send("country_name_#{locale}"), region: region.slug, lodging_count: region.lodging_count, url: lodgings_path(locale: locale) } }
    end

    def themes
      Experience.search(params[:query], {
        fields: ["name_#{locale}"],
        match: :text_middle,
        limit: 10,
        load: false,
        misspellings: {below: 5},
        where: { publish: true }
      }).map{ |experience| { name: experience.send("name_#{locale}"), id: experience.id, type: 'experience', lodging_count: experience.lodging_count, experience: experience.send("slug_#{locale}"), url: lodgings_path(locale: locale) } }
    end

    def hotels
      Lodging.search(params[:query], {
        fields: [:name],
        match: :text_middle,
        limit: 6,
        load: false,
        misspellings: {below: 5},
        where: { presentation: 'as_parent', published: true }
      }).map{ |lodging| { name: lodging.name, id: lodging.id, type: 'hotel', slug: lodging.slug } }
    end
end
