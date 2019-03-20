class LodgingsController < ApplicationController
  before_action :set_lodging, only: [:show]
  skip_before_action :verify_authenticity_token, only: [:index]
  layout 'calendar', only: :calendar

  # GET /lodgings
  # GET /lodgings.json
  def index
    @custom_text = CustomText.find_by(id: params[:custom_text])
    @custom_texts = CustomText.home_page unless @custom_text.present?
    @lodgings = SearchLodgings.call(params, @custom_text)
    @lodgings.map{|lodging| lodging.cumulative_price(params.clone)}
    @amenities = Amenity.includes(:translations).all
    @experiences = Experience.includes(:translations).all
    @title = @custom_text.try(:meta_title)
  end

  # GET /lodgings/1
  # GET /lodgings/1.json
  def show
    @lodgings = SearchSimilarLodgings.call(@lodging, params)
    @lodgings.map{|lodging| lodging.cumulative_price(params.clone)}
    @reservation = @lodging.reservations.build
    @reviews = @lodging.all_reviews.includes(:user, :reservation).page(params[:page]).per(2)
    @lodging_children = @lodging.lodging_children.published.includes(:availabilities, :translations) if @lodging.as_parent?
    @title = @lodging.meta_title
  end

  def price_details
    @lodging = Lodging.find(params[:values].split(',')[-1])
    results = @lodging.price_details(params[:values].split(','))

    if @lodging.flexible_search
      @rates = results.map{ |result| result[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }}
      @search_params = results.map{ |result| result[:search_params] }
      @discounts = []
      @search_params.each do |param|
        @discounts << @lodging.discount_details([param[:check_in], param[:check_out]])
      end
      @valid = results.map{ |result| result[:valid] }
    else
      @rates = results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }
      @search_params = results[:search_params]
      @valid = results[:valid]
      @discounts = @lodging.discount_details(params[:values].split(','))
    end
    @cleaning_costs = @lodging.cleaning_costs.for_guests(params[:values].split(',')[2].to_i + params[:values].split(',')[3].to_i)
  end

  def calendar
    @lodging = Lodging.published.friendly.find(params[:id])
    response.headers.delete "X-Frame-Options"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end
end
