module Crm
  module V1
    module OwnersHelper
      def calculate_commissions(owners)
        owners.map do |owner|
          {
            commission_previous_7_year: owner.commission_previous_7_year.to_f.round(2),
            commission_previous_6_year: owner.commission_previous_6_year.to_f.round(2),
            commission_previous_5_year: owner.commission_previous_5_year.to_f.round(2),
            commission_previous_4_year: owner.commission_previous_4_year.to_f.round(2),
            commission_previous_3_year: owner.commission_previous_3_year.to_f.round(2),
            commission_previous_2_year: owner.commission_previous_2_year.to_f.round(2),
            commission_previous_1_year: owner.commission_previous_1_year.to_f.round(2),
            commission_next_1_year: owner.commission_next_1_year.to_f.round(2)
          }
        end
      end
    end
  end
end
