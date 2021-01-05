class OpenGdsCreateRatesJob < ApplicationJob
  queue_as :default

  def perform(rates)
    OpenGds::CreateRates.call(rates)
  end
end
