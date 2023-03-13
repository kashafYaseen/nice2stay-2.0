class GetCampaigsData
  include Rails.application.routes.url_helpers

  attr_reader :type
  attr_reader :section
  attr_reader :locale

  def self.call(type, section, locale)
    self.new(type, section, locale).call
  end

  def initialize(type, section, locale)
    @type = type
    @section = section
    @locale = locale
  end

  def call
    Campaign.search('*', { where: { "#{type}": true, "#{section}": true }, load: false}).map { |campaign| {
      name: campaign.send("title_#{locale}"),
      description: campaign.send("description_#{locale}"),
      id: campaign.id,
      type: "#{type}_campaign",
      images: campaign.images,
      url: campaign.send("redirect_url_#{locale}")
    }}
  end
end
