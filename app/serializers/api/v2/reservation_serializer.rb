class Api::V2::ReservationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :booking_id, :lodging_child_name, :lodging_id, :created_at,
             :request_status, :booking_confirmed, :booking_status, :total_rent,
             :rent, :cleaning_cost, :discount, :identifier, :check_in, :check_out,
             :adults, :children, :infants, :guest_centric_booking_id, :offer_id,
             :meal_id, :meal_price, :gc_errors, :rooms, :meal_tax, :tax, :additional_fee,
             :room_type, :gc_policy

  attributes :lodging do |reservation|
    Api::V2::LodgingSerializer.new(reservation.lodging)
  end

  attributes :review do |reservation|
    Api::V2::ReviewSerializer.new(reservation.review)
  end
end
