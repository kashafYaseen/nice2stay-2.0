class Crm::V1::ExperienceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :guests, :priority, :publish, :short_desc, :name_nl, :name_en

end
