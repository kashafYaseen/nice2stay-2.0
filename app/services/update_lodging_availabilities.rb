class UpdateLodgingAvailabilities
  attr_reader :lodging
  attr_reader :availabilities

  def self.call(lodging, availabilities)
    self.new(lodging, availabilities).call
  end

  def initialize(lodging, availabilities)
    @lodging = lodging
    @availabilities = availabilities
  end

  def call
    return unless availabilities.present?
    update_availabilities
  end

  private
    def update_availabilities
      availabilities.each do |availability|
        lodging.availabilities.with_in(availability[:from], availability[:to]).delete_all
      end
    end
end
