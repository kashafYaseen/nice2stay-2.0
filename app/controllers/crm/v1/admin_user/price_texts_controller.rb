class Crm::V1::AdminUser::PriceTextsController < Crm::V1::ApiController

  before_action :set_price_text, only: [:update, :destroy]
  before_action :set_accommodation, only: [:create]

  def index
    render json: Crm::V1::PriceTextSerializer.new(PriceText.all.includes([:lodging])).serialized_json, status: :ok
    # render json: Crm::V1::PriceTextSerializer.new(PriceText.all).serialized_json, status: :ok
  end

  def new
  end

  def create
    @price_text = @lodging.build_price_text(price_text_params)
    if @price_text.save
      render json: Crm::V1::PriceTextSerializer.new(@price_text).serialized_json, status: :ok
    else
      unprocessable_entity(@price_text.errors)
    end
  end

  def edit
  end

  def update
    if @price_text.update(price_text_params)
      render json: Crm::V1::PriceTextSerializer.new(@price_text).serialized_json, status: :ok
    else
      unprocessable_entity(@price_text.errors)
    end
  end

  def destroy
    @price_text.destroy
    render json: { removed: @price_text.destroyed? }, status: :ok
  end

  private
    def price_text_params
      params.require(:price_text).permit(
        :season_text,
        :including_text,
        :deposit_text,
        :options_text,
        :particularities_text,
        :payment_terms_text,
        :lodging_id
      )
    end

    def set_accommodation
      @lodging = Lodging.find(params[:price_text][:lodging_id])
    end

    def set_price_text
      @price_text = PriceText.find(params[:id])
    end
end
