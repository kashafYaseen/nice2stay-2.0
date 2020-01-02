class Api::V2::LeadSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :from, :to, :adults, :childrens, :extra_information, :user_id

  attributes :countries do |lead|
    Api::V2::CountrySerializer.new(lead.countries)
  end

  attributes :user, if: Proc.new { |lead, params| params.present? && params[:auth].present? } do |lead, params|
    Api::V2::UserSerializer.new(lead.user, { params: { auth_token: params[:auth] } })
  end
end
