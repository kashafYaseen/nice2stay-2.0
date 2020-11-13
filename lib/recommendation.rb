module Reccommendation
  def recommended_lodgings
    other_users = User.where.not(id: self.id).includes(:reservations, :reserved_lodgings, reserved_lodgings: [:translations])
    recommended = Hash.new(0)

    other_users.each do |user|
      common_reserved_lodgings = user.reserved_lodging_slugs && self.reserved_lodging_slugs

      weight = common_reserved_lodgings.size.to_f / user.reserved_lodging_slugs.size.to_f rescue 0.0

      (user.reserved_lodging_slugs - common_reserved_lodgings).each do |recommended_lodging|
        recommended[recommended_lodging] += weight
      end
    end

    recommended.sort_by { |key, value| value }.reverse.slice(0, 5)
  end
end
