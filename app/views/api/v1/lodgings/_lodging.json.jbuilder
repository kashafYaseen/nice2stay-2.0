json.id            lodging.id
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
json.created_at    lodging.created_at
json.updated_at    lodging.updated_at

json.rules do
  json.array! lodging.rules, partial: 'api/v1/rules/rule', as: :rule
end

json.discounts do
  json.array! lodging.discounts, partial: 'api/v1/discounts/discount', as: :discount
end

json.availabilities do
  json.array! lodging.availabilities, partial: 'api/v1/availabilities/availability', as: :availability
end
