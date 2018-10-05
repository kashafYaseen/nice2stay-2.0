class LodgingsController < ApplicationController
  before_action :set_lodging, only: [:show]
  skip_before_action :verify_authenticity_token, only: [:index]

  # GET /lodgings
  # GET /lodgings.json
  def index
    @lodgings = SearchLodgings.call(params)
    @amenities = Amenity.includes(:translations).all
    @experiences = Experience.includes(:translations).all
  end

  # GET /lodgings/1
  # GET /lodgings/1.json
  def show
    @lodgings = SearchSimilarLodgings.call(@lodging, params)
    @reservation = @lodging.reservations.build
    @reviews = @lodging.all_reviews.includes(:user, :reservation).page(params[:page]).per(2)
    @lodging_children = @lodging.lodging_children.includes(:availabilities, :translations) if @lodging.as_parent?
  end


  def price_details
    @lodging = Lodging.find(params[:values].split(',')[-1])
    results = @lodging.price_details(params[:values].split(','))

    if @lodging.flexible_search
      @rates = results.map{ |result| result[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }}
      @search_params = results.map{ |result| result[:search_params] }
      @valid = results.map{ |result| result[:valid] }
    else
      @rates = results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }
      @search_params = results[:search_params]
      @valid = results[:valid]
    end
    @discount = @lodging.discount_details(params[:values].split(','))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lodging
      @lodging = Lodging.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end
end
