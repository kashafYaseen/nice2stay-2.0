json.id            lodging.id
json.title         lodging.title
json.subtitle      lodging.subtitle
json.street        lodging.street
json.city          lodging.city
json.zip           lodging.zip
json.state         lodging.state
json.latitude      lodging.latitude
json.longitude     lodging.longitude
json.beds          lodging.beds
json.baths         lodging.baths
json.sq__ft        lodging.sq__ft
json.sale_date     lodging.sale_date
json.price         lodging.price
json.lodging_type  lodging.lodging_type
json.adults        lodging.adults
json.children      lodging.children
json.infants       lodging.infants
json.description   lodging.description
json.created_at    lodging.created_at
json.updated_at    lodging.updated_at

# json.owner do
#   json.partial! 'api/v1/owners/owner', owner: lodging.owner
# end

# json.specifications do
#   json.array! lodging.specifications, partial: 'api/v1/specifications/specification', as: :specification
# end

# json.rules do
#   json.array! lodging.rules, partial: 'api/v1/rules/rule', as: :rule
# end

# json.discounts do
#   json.array! lodging.discounts, partial: 'api/v1/discounts/discount', as: :discount
# end

# json.reviews do
#   json.array! lodging.reviews, partial: 'api/v1/reviews/review', as: :review
# end

# json.availabilities do
#   json.array! lodging.availabilities, partial: 'api/v1/availabilities/availability', as: :availability
# end
