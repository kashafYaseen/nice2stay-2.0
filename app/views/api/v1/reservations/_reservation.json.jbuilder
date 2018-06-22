json.id          reservation.id
json.check_in    reservation.check_in
json.check_out   reservation.check_out
json.adults      reservation.adults
json.children    reservation.children
json.infants     reservation.infants
json.created_at  reservation.created_at
json.updated_at  reservation.updated_at

json.user do
  json.partial! 'api/v1/users/user', user: reservation.user
end

json.lodging do
  json.partial! 'api/v1/lodgings/lodging', lodging: reservation.lodging
end
