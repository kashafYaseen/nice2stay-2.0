json.id            reservation.id
json.check_in      reservation.check_in
json.check_out     reservation.check_out
json.adults        reservation.adults
json.children      reservation.children
json.infants       reservation.infants
json.rent          reservation.rent
json.cleaning_cost reservation.cleaning_cost
json.discount      reservation.discount
json.total_price   reservation.total_price
json.created_at    reservation.created_at
json.updated_at    reservation.updated_at

json.review do
  json.partial! 'api/v1/reviews/review', review: reservation.review if reservation.review.present?
end

json.lodging do
  json.partial! 'api/v1/lodgings/lodging', lodging: reservation.lodging
end
