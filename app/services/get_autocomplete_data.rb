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
  end

  private
    def lodgings
      Lodging.search(params[:query], {
        fields: ["name"],
        match: :word_start,
        limit: 5,
        load: false,
        misspellings: {below: 5}
      }).map{ |lodging| { name: lodging.name, id: lodging.id, type: 'lodging', url: lodging_path(lodging.slug, locale: locale) } }
    end

    def campaigns
      Campaign.search(params[:query], {
        fields: ["title"],
        match: :word_start,
        limit: 5,
        load: false,
        misspellings: {below: 5}
      }).map{ |campaign| { name: campaign.title, id: campaign.id, type: 'campaign', url: campaign.url } }
    end
end
