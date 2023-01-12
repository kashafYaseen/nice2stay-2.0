class GetCampaigsData
  include Rails.application.routes.url_helpers

  attr_reader :type
  attr_reader :locale

  def self.call(type, locale)
    self.new(type, locale).call
  end

  def initialize(type, locale)
    @type = type
    @locale = locale
  end

  def call
    Campaign.search('*', { where: { "#{type}": true }, load: false}).map { |campaign| {
      name: campaign.send("title_#{locale}"),
      id: campaign.id,
      type: "#{type}_campaign",
      images: campaign.images,
      url: campaign.send("redirect_url_#{locale}")
    }}
  end
end
