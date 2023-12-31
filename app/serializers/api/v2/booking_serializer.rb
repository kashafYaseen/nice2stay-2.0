class Api::V2::BookingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :confirmed, :created_at, :identifier, :pre_payment, :final_payment, :pre_payed_at, :final_payed_at,
             :total_security_deposit, :total_security_deposit_on_location, :security_payed_at, :booking_status, :canceled, :total_payment

  attributes :pre_paid do |booking|
    booking.step_passed?(:pre_paid)
  end

  attributes :pre_payment_amount do |booking|
    booking.pre_payment_amount.to_f
  end

  attributes :final_payment_amount do |booking|
    booking.final_payment_amount.to_f
  end

  attributes :latest_checkout, if: Proc.new { |booking| booking.reservations.present? } do |booking|
    booking.reservations.pluck(:check_out).max > Date.today
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
