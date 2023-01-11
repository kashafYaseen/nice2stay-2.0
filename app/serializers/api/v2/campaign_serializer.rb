class Api::V2::CampaignSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :image, :description
end
