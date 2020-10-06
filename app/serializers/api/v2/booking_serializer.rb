class Api::V2::BookingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :confirmed, :created_at, :identifier, :pre_payment, :pre_payment_amount,
             :final_payment, :final_payment_amount, :pre_payed_at, :final_payed_at, :booking_status, :canceled, :total_payment

  attributes :pre_paid do |booking|
    booking.step_passed?(:pre_paid)
  end

  attributes :fully_paid do |booking|
    booking.step_passed?(:fully_paid)
  end

  attributes :reservations, if: Proc.new { |booking, params| params.present? && params[:reservations].present? } do |booking, params|
    Api::V2::ReservationSerializer.new(booking.reservations.not_canceled)
  end

  attributes :user, if: Proc.new { |booking, params| params.present? && params[:auth].present? } do |booking, params|
    Api::V2::UserSerializer.new(booking.user, { params: { auth_token: params[:auth] } })
  end
end
