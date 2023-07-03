class Crm::V1::AdminUser::DiscountsController < Crm::V1::ApiController

  before_action :set_discount, only: [:update, :destroy]
  before_action :set_accommodation, only: [:create]

  def index
    render json: Crm::V1::DiscountSerializer.new(Discount.all.includes([:lodging])).serialized_json, status: :ok
    # render json: Crm::V1::DiscountSerializer.new(Discount.all).serialized_json, status: :ok
  end

  def new
  end

  def create
    @discount = @lodging.discounts.build(discount_params)
    if @discount.save
      render json: Crm::V1::DiscountSerializer.new(@discount).serialized_json, status: :ok
    else
      unprocessable_entity(@discount.errors)
    end
  end

  def edit
  end

  def update
    if @discount.update(discount_params)
      render status: :created
      render json: Crm::V1::DiscountSerializer.new(@discount).serialized_json, status: :ok
    else
      unprocessable_entity(@discount.errors)
    end
  end

  def destroy
    @discount.destroy
    render json: { removed: @discount.destroyed? }, status: :ok
  end

  private
    def discount_params
      params.require(:discount).permit(
        :short_desc,
        :description,
        :value,
        :from,
        :to,
        :discount_type,
        # :created_by #
        :publish,
        :valid_to,
        :lodging_id,
        :start_date,
        :end_date,
        :minimum_days
      )
    end

    def set_accommodation
      @lodging = Lodging.find(params[:discount][:lodging_id])
    end

    def set_discount
      @discount = Discount.find(params[:id])
    end
end
