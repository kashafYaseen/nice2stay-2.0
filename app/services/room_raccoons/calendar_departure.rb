class RoomRaccoons::CalendarDeparture
  attr_reader :room_rate,
              :availabilites,
              :params

  def self.call(room_rate:, params:)
    new(room_rate: room_rate, params: params).call
  end

  def initialize(room_rate:, params:)
    @room_rate = room_rate
    @params = params

  end
end
