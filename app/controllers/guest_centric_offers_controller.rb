class GuestCentricOffersController < ApplicationController
  before_action :set_lodging

  def show
    @guest_centric = GetGuestCentricOffers.call(@lodging, params[:reservation].merge(locale: locale))
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end
end
