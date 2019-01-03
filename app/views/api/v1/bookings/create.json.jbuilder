json.id     @booking.id
json.uid    @booking.uid
json.crm_id @booking.crm_id

json.user do
  json.partial! 'api/v1/users/user', user: @booking.user if @booking.user.present?
end

json.reservations do
  json.array! @booking.reservations, partial: 'api/v1/reservations/reservation', as: :reservation
end
