json.id              availability.id
json.available_on    availability.available_on
json.check_out_only  availability.check_out_only
json.created_at      availability.created_at
json.updated_at      availability.updated_at

json.prices do
  json.array! availability.prices, partial: 'api/v1/prices/price', as: :price
end
