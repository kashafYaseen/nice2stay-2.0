json.id            lodging.id
json.name          lodging.name
json.summary       lodging.summary
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
json.short_desc    lodging.short_desc
json.created_at    lodging.created_at
json.updated_at    lodging.updated_at
json.images        lodging.images

json.owner do
  json.partial! 'api/v1/owners/owner', owner: lodging.owner
end
