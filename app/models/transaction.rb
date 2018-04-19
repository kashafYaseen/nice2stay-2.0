class Transaction < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  searchkick locations: [:location], text_start: [:city]
 

  def address
    [street, city, zip, state].compact.join(", ")
  end

  def address_changed?
    street_changed? || city_changed? || zip_changed? || state_changed?
  end

  def search_data
    attributes.merge location: { lat: latitude, lon: longitude }

  end

  def self.facets_search(params)
    query = params[:query].presence || "*"
    conditions = {}
    conditions[:beds] = params[:beds] if params[:beds].present?
    conditions[:baths] = params[:baths] if params[:baths].present?

    transactions = Transaction.search query, where: conditions, aggs: [:beds, :baths], per_page: 10, page: params[:page]
      
end

  mount_uploader :image, ImageUploader

end
