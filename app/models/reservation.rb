class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
  has_many :rules, through: :lodging

  validates :check_in, :check_out, presence: true
  validate :availability
  validate :check_out_only
  validate :accommodation_rules

  after_create :update_lodging_availability

  delegate :active, to: :rules, prefix: true, allow_nil: true

  private

    def update_lodging_availability
      update_check_in_day
      lodging.availabilities.where(available_on: (check_in+1.day..check_out-1.day).map(&:to_s)).destroy_all
      lodging.availabilities.where(available_on: check_out, check_out_only: true).delete_all
    end

    def availability
      return unless check_in.present? && check_out.present? && lodging.present?
      errors.add(:check_in, "& check out dates must be different") if (check_out - check_in).to_i < 1
      available_days = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s), check_out_only: false).count
      errors.add(:base, "lodging is not available for selected dates") if available_days < (check_out - check_in).to_i
    end

    def check_out_only
      return unless check_in.present? && check_out.present? && lodging.present?
      check_out_days = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s), check_out_only: true)
      errors.add(:base, "#{check_out_days.pluck(:available_on)} only available for check out") if check_out_days.present?
    end

    def accommodation_rules
      return unless rules_active(check_in, check_out).present? && lodging.present?
      rules_active(check_in, check_out).each do |rule|
        if rule.days_multiplier.present?
          errors.add(:base, "Minimaal is #{rule.days_multiplier} nachten verblijf in deze periode") unless (check_out - check_in).to_i % rule.days_multiplier == 0
        end

        if rule.check_in_days.present? & check_in.present?
          errors.add(:base, "Check in day should be #{rule.check_in_days}") unless check_in.strftime("%A") == rule.check_in_days
        end
      end
    end

    def update_check_in_day
      days = lodging.availabilities.where(available_on: [check_in-1.day, check_in]).order(available_on: :desc)
      return days.take.update(check_out_only: true) if days.size == 2
      days.take.delete
    end
end
