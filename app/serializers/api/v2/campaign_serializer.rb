class Api::V2::CampaignSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :image, :menu_title, :h1_text
end
