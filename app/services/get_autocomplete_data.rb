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
  end

  private
    def lodgings
      Lodging.search(params[:query], {
        fields: [:extended_name, :h1],
        match: :word_start,
        limit: 6,
        load: false,
        misspellings: {below: 5},
        where: { presentation: ['as_parent', 'as_standalone'] }
      }).map{ |lodging| { name: lodging.extended_name, title: lodging.h1, type: 'lodging', url: lodging_path(lodging.slug, locale: locale) } }
    end

    def campaigns
      Campaign.search(params[:query], {
        fields: [:title],
        match: :word_start,
        limit: 5,
        load: false,
        misspellings: {below: 5},
        where: { collection: true, popular_homepage: true }
      }).map{ |campaign| { name: campaign.title, type: 'campaign', url: campaign.url } }
    end

    def countries
      Country.search(params[:query], {
        fields: [:name],
        match: :word_start,
        limit: 5,
        load: false,
        misspellings: {below: 5},
        where: { disable: false }
      }).map{ |country| { name: country.name, type: 'country', url: country_path(country.slug, locale: locale) } }
    end

    def regions
      Region.search(params[:query], {
        fields: [:name],
        match: :word_start,
        limit: 5,
        load: false,
        misspellings: {below: 5},
        where: { disable: false }
      }).map{ |region| { name: region.name, type: 'region', url: country_region_path(region.country_slug, region.slug, locale: locale) } }
    end
end
