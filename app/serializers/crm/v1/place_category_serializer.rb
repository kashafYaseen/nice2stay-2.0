class Crm::V1::PlaceCategorySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :color_code, :name_nl, :name_en

end
