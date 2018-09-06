class Api::V1::CampaignsController < Api::V1::ApiController
  def create
    @campaign = SaveCampaignDetails.call(params)

    if @campaign.valid?
      render json: @campaign, status: :created
    else
      render json: @campaign.errors, status: :unprocessable_entity
    end
  end
end
