class GuestCentricOffersController < ApplicationController
  before_action :set_lodging

  def show
    @guest_centric = GetGuestCentricOffers.call(@lodging, params[:reservation].merge(locale: locale))
  end

  def rates
    @guest_centric_rates, @total = GetGuestCentricRates.call(@lodging, params[:reservation])['response'], 0
    @guest_centric_rates.each { |rate| @total += rate['value'].to_f }
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end
end
