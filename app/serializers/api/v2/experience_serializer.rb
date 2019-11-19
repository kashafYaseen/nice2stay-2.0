class Api::V2::ExperienceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :tag, :slug, :short_desc
end
