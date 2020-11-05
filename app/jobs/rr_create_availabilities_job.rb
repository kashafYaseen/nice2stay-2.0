class RrCreateAvailabilitiesJob < ApplicationJob
  queue_as :default

  def perform(hotel, parsed_data)
    availabilities = []
    rules = []

    rooms = hotel.lodging_children.joins(:room_type).distinct.includes(:availabilities, :rules).where(room_types: { code: parsed_data.map {|data| data[:room_type_code] }.uniq })
    parsed_data.each do |data|
      dates = (data[:start_date]..data[:end_date]).map(&:to_s)
      stays = data[:stays].length == 2 ? (data[:stays][0]..data[:stays][1]).map(&:to_s) : data[:stays]
      rooms.each do |room|
        available_on_dates = room.availabilities.pluck(:available_on)
        dates.each do |date|
          availabilities << room.availabilities.new(available_on: date, created_at: DateTime.now, updated_at: DateTime.now) unless available_on_dates.include?(date.to_date)
        end

        check_response = restriction_status(data[:status], data[:restriction])
        if stays.present? || check_response.present?
          rule_index = room.rules.find_index {|rule| rule.start_date == data[:start_date].to_date && rule.end_date == data[:end_date].to_date }
          rule = rule_index.present? ?
                  room.rules[rule_index] :
                  room.rules.new(start_date: data[:start_date], end_date: data[:end_date], created_at: DateTime.now, updated_at: DateTime.now)

          if check_response.present?
            check_response == "check_in_closed" ? rule.rr_check_in_closed = true : rule.rr_check_out_closed = true
          end
          rule.minimum_stay = stays
          rules << rule if rule.new_record? || rule.changed?
        end
      end
    end

    Availability.import availabilities, batch_size: 150 if availabilities.present?
    Rule.import rules, batch: 150, on_duplicate_key_update: { columns: [ :rr_check_in_closed, :rr_check_out_closed, :start_date, :end_date, :minimum_stay ] } if rules.present?
  end

  def restriction_status(status, restriction)
    return "check_out_closed" if status == "close" && restriction == "departure"
    return "check_in_closed" if status == "close" && restriction == "arrival"
  end
end
