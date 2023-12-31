class Api::V2::RegionsController < Api::V2::ApiController
  def index
    params[:search][:country_id_in] = JSON.parse(params[:search][:country_id_in]) if params[:search].present? && params[:search][:country_id_in].present?
    params[:search][:country_id_in] = Country.where(slug: params[:search][:country_slug]).ids if params[:search].present? && params[:search][:country_slug].present?
    regions = Region.ransack(params[:search]).result
    render json: Api::V2::RegionSerializer.new(regions).serialized_json, status: :ok
  end
end
