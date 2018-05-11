class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :check_in, :check_out, presence: true

  after_create :update_lodging_availability

  private

    def update_lodging_availability
      lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s)).destroy_all
    end
end
