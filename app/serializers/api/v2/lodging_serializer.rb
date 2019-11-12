class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :summary, :title, :subtitle, :street, :city,
             :zip, :state, :latitude, :longitude, :beds, :baths, :sq__ft,
             :sale_date, :price, :lodging_type, :adults, :children, :infants,
             :description, :short_desc, :images, :created_at, :updated_at
end
