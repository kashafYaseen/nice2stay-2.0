class Api::V1::CampaignsController < Api::V1::ApiController
  def create
    @campaign = SaveCampaignDetails.call(params)

    if @campaign.valid?
      render json: @campaign, status: :created
    else
      unprocessable_entity(@campaign.errors)
    end
  end
end
