json.lodgings do
  json.array! @lodgings, partial: 'api/v2/lodgings/lodging', as: :lodging
end
