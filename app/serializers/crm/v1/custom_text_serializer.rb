class Crm::V1::CustomTextSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :h1_text, :meta_title, :p_text

  attributes :relatives do |custom_text|
    custom_text.relatives.pluck(:h1_text).try(:join, " | ")
  end
end
