class Api::V2::ReservationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :booking_id, :lodging_child_name, :lodging_id, :created_at,
             :request_status, :booking_confirmed, :booking_status, :total_rent,
             :rent, :cleaning_cost, :discount, :identifier, :check_in, :check_out,
             :adults, :children, :infants, :guest_centric_booking_id, :offer_id,
             :meal_id, :meal_price, :gc_errors, :rooms, :meal_tax, :tax, :additional_fee,
             :room_type, :gc_policy, :open_gds_deposit_amount, :open_gds_online_payment,
             :pre_payment_percentage, :final_payment_percentage, :payment_in_percentage,
             :security_deposit, :include_deposit

  attributes :lodging do |reservation|
    Api::V2::LodgingSerializer.new(reservation.lodging)
  end

  attributes :review do |reservation|
    Api::V2::ReviewSerializer.new(reservation.review)
  end

  attribute :rate_plan do |reservation|
    Api::V2::RatePlanSerializer.new(reservation.rate_plan)
  end

  attribute :supplements do |reservation|
    Api::V2::ReservedSupplementSerializer.new(reservation.reserved_supplements)
  end
end
