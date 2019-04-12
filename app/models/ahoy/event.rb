class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  #after_create :sent_details

  private
    def sent_details
      SendAhoyEventDetailsJob.perform_later(self.id)
    end
end
