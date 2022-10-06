class Api::V2::ReservedSupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :supplement_type, :rate_type, :rate, :child_rate, :total, :reservation_id, :quantity

end
