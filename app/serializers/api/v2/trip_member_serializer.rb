class Api::V2::TripMemberSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id, :trip_id, :created_at

  attributes :user do |trip_member|
    Api::V2::UserSerializer.new(trip_member.user)
  end
end
