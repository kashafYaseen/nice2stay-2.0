FactoryBot.define do
  factory :room_type do
    code { 'FB' }
    name { 'Fabulous Room' }
    description { 'Fabulous Room' }
    extra_beds { 2 }
    extra_beds_for_children_only { false }
    adults { 2 }
    children { 0 }
    infants { 0 }
    # parent_lodging { create(:lodging) }
  end
end
