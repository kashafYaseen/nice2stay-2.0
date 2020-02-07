class Api::V1::GcOffersController < Api::V1::ApiController
  def create
    @gc_offer = Synchronization::SaveGcOfferDetails.call(params)

    if @gc_offer.valid?
      render json: @gc_offer, status: :created
    else
      unprocessable_entity(@gc_offer.errors)
    end
  end
end
