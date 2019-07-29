class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true

  #after_create :sent_details

  def technology
    [browser, os, device_type].map(&:presence).compact.join(', ')
  end

  def location
    [city, region, country].map(&:presence).compact.join(', ')
  end

  private
    def sent_details
      SendAhoyVisitDetailsJob.perform_later(self.id)
    end
end
