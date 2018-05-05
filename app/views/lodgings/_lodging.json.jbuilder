json.extract! lodging, :id, :street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude, :created_at, :updated_at
json.url lodging_url(lodging, format: :json)
