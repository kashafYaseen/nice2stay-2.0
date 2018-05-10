class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :check_in, :check_out, presence: true
  validate :availability

  after_create :update_lodging_availability

  private

    def update_lodging_availability
      lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s)).destroy_all
    end

    def availability
      return unless check_in.present? && check_out.present?
      available_days = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s)).count
      errors.add(:base, "lodging is not available for selected dates") if available_days < (check_out - check_in).to_i
    end
end
