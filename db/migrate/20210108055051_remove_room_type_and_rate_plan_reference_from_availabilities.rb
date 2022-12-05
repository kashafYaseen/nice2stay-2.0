class RemoveRoomTypeAndRatePlanReferenceFromAvailabilities < ActiveRecord::Migration[5.2]
  def up
    add_reference :availabilities, :room_rate, foreign_key: { on_delete: :cascade }
    room_rates = RoomRate.all
    Availability.where.not(room_type_id: nil, rate_plan_id: nil).each do |availability|
      room_rate = room_rates.find do |rate|
        rate[:room_type_id] == availability.room_type_id && rate[:rate_plan_id] == availability.rate_plan_id
      end
      availability.room_rate_id = room_rate.id
      availability.save(validate: false)
    end
    remove_reference :availabilities, :room_type, index: true
    remove_reference :availabilities, :rate_plan, foreign_key: { on_delete: :cascade }
  end

  def down
    add_reference :availabilities, :room_type, index: true
    add_reference :availabilities, :rate_plan, foreign_key: { on_delete: :cascade }
    room_rates = RoomRate.all
    Availability.where.not(room_rate_id: nil).each do |availability|
      room_rate = room_rates.find do |rate|
        rate[:id] == availability.room_rate_id
      end
      availability.room_type_id = room_rate.room_type_id
      availability.rate_plan_id = room_rate.rate_plan_id
      availability.save(validate: false)
    end
    remove_reference :availabilities, :room_rate, foreign_key: { on_delete: :cascade }
  end
end
