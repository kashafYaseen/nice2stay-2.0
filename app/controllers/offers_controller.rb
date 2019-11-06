class OffersController < ApplicationController
  before_action :set_offer

  def show
    @lodgings = SearchLodgings.call({ lodging_ids: @offer.lodgings.ids })
    @total_lodgings = CountTotalLodgings.call()
  end

  private
    def set_offer
      @offer = Offer.find(params[:id])
    end
end
