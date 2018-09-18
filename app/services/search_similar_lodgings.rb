class SearchSimilarLodgings
  attr_reader :params
  attr_reader :lodging

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @params = params
    @lodging = lodging
  end

  def call
    update_params
    SearchLodgings.call(params)
  end

  private
    def update_params
      params[:within] = "300km"
      params[:limit] = 6
      params[:lodging_type] = lodging.lodging_type unless params[:lodging_type].present?
      params[:latitude] = lodging.latitude
      params[:longitude] = lodging.longitude
    end
end
