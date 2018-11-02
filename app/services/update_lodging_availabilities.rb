class UpdateLodgingAvailabilities
  attr_reader :lodging
  attr_reader :availabilities
  attr_reader :lodging_availabilities

  def self.call(lodging, availabilities)
    self.new(lodging, availabilities).call
  end

  def initialize(lodging, availabilities)
    @lodging = lodging
    @availabilities = availabilities
    @lodging_availabilities = lodging.availabilities
  end

  def call
    return unless availabilities.present?
    update_availabilities
  end

  private
    def update_availabilities
      availabilities.each do |availability|
        lodging_availabilities.with_in(availability[:from], availability[:to]).delete_all
        previous_day = lodging_availabilities.find_by(available_on: (availability[:from].to_date() -1.day))
        if previous_day.present? && previous_day.check_out_only
          lodging_availabilities.find_by(available_on: availability[:from]).delete
        else
          lodging_availabilities.check_out_only!(availability[:from].to_date)
        end
        lodging_availabilities.not_available!(availability[:to].to_date)
      end
    end
end
