class Crm::V1::PriceTextSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :season_text, :including_text, :deposit_text,
              :options_text, :particularities_text, :payment_terms_text


end
