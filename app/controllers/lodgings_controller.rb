class LodgingsController < ApplicationController
  skip_before_action :set_booking, :set_wishlists, :set_custom_texts, :set_pages, if: proc { |c| request.xhr? }
  before_action :set_lodging, only: [:show]
  before_action :set_collection, only: [:index]
  skip_before_action :verify_authenticity_token, only: [:index]
  after_action :track_action, only: [:index, :show]
  layout 'calendar', only: :calendar

  # GET /lodgings
  # GET /lodgings.json
  def index
    @lodgings = SearchLodgings.call(params, @custom_text)
    @total_lodgings = CountTotalLodgings.call()
    @amenities = Amenity.includes(:translations).all
    @experiences = Experience.includes(:translations).all
    @regions = Region.active
    @title = @custom_text.try(:meta_title)

  rescue Searchkick::InvalidQueryError
    redirect_back fallback_location: lodgings_path, alert: 'Invalid search parameters, please try again'
  end

  # GET /lodgings/1
  # GET /lodgings/1.json
  def show
    @lodgings = SearchSimilarLodgings.call(@lodging, params)
    @places = SearchPlaces.call(params.merge(latitude: @lodging.latitude, longitude: @lodging.longitude))
    @lodgings.map{|lodging| lodging.cumulative_price(params.clone)}
    @reservation = @lodging.reservations.build
    @reviews = @lodging.all_reviews.includes(:user, :reservation).page(params[:page]).per(2)
    @lodging_children = @lodging.lodging_children.published.includes(:availabilities, :translations) if @lodging.as_parent?
    @title = @lodging.meta_title

    if @lodging.guest_centric?
      @disable_dates = @lodging.gc_not_available_on(params)
      @check_in = @lodging.first_available_date(@disable_dates)
      @children_gc_ids = @lodging.lodging_children.pluck(:guest_centric_id)
    elsif @lodging.booking_expert?
      @disable_dates = @lodging.be_not_available_on
      @check_in = @lodging.first_available_date(@disable_dates)
    end
  end

  def price_details
    @lodging = Lodging.find(params[:values].split(',')[-1])
    results = @lodging.price_details(values: params[:values].split(','))
    @errors = results[:errors] if results.has_key? :errors
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

  def cumulative_price
    @lodgings = Lodging.where(id: params[:ids].try(:split, ','))
    @lodgings.map{ |lodging| lodging.cumulative_price(params.clone) }
  end

  def quick_view
    @lodging = Lodging.published.friendly.find(params[:id])
    @reviews = @lodging.all_reviews.includes(:user, :reservation).limit(3)
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end

    def set_collection
      @custom_text = CustomText.find_by(id: params[:custom_text])
      # return @collection = @custom_text.relatives if @custom_text.present?
      # @collection = CustomText.home_page unless params[:country].present? || params[:region].present? || params[:bounds].present?
    end

    def track_action
      ahoy.track "Lodgings Search", request.parameters.except('utf8')
    end
end
