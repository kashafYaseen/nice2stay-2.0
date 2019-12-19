class Api::V2::ReservationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :booking_id, :lodging_child_name, :lodging_id, :created_at,
             :request_status, :booking_confirmed, :booking_status, :total_rent,
             :rent, :cleaning_cost, :discount, :identifier, :check_in, :check_out,
             :adults, :children, :infants

  attributes :lodging do |reservation|
    Api::V2::LodgingSerializer.new(reservation.lodging)
  end
end
