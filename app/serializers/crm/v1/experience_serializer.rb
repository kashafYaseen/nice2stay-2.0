class Crm::V1::ExperienceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :guests, :priority, :publish

end
