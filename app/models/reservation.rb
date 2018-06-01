class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
  has_many :rules, through: :lodging

  validates :check_in, :check_out, presence: true
  validate :availability
  validate :accommodation_rules

  after_create :update_lodging_availability

  delegate :active, to: :rules, prefix: true, allow_nil: true

  private

    def update_lodging_availability
      lodging.availabilities.where(available_on: (check_in+1.day..check_out-1.day).map(&:to_s)).destroy_all
    end

    def availability
      return unless check_in.present? && check_out.present?
      errors.add(:check_in, "& check out dates must be different") if (check_out - check_in).to_i < 1
      available_days = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s)).count
      errors.add(:base, "lodging is not available for selected dates") if available_days < (check_out - check_in).to_i
    end

    def accommodation_rules
      return unless rules_active.present?
      rules_active.each do |rule|
        if rule.days_multiplier.present?
          errors.add(:base, "Reserve days should be multiple of #{rule.days_multiplier}") unless (check_out - check_in).to_i % rule.days_multiplier == 0
        end

        if rule.check_in_days.present? & check_in.present?
          errors.add(:base, "Check in day should be #{rule.check_in_days}") unless check_in.strftime("%A") == rule.check_in_days
        end
      end
    end
end
