class Api::V2::PageSerializer
  include FastJsonapi::ObjectSerializer
  attributes  :id, :content, :slug
end
