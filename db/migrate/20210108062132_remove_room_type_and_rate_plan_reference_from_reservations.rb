class RemoveRoomTypeAndRatePlanReferenceFromReservations < ActiveRecord::Migration[5.2]
  def up
    add_reference :reservations, :room_rate, foreign_key: { on_delete: :nullify }
    room_rates = RoomRate.all
    Reservation.where.not(room_type_id: nil, rate_plan_id: nil).each do |reservation|
      room_rate = room_rates.find do |rate|
        rate[:room_type_id] == reservation.room_type_id && rate[:rate_plan_id] == reservation.rate_plan_id
      end
      reservation.room_rate_id = room_rate.id
      reservation.save(validate: false)
    end
    remove_reference :reservations, :room_type, index: true
    remove_reference :reservations, :rate_plan, index: true
  end

  def down
    add_reference :reservations, :room_type, index: true
    add_reference :reservations, :rate_plan, index: true
    room_rates = RoomRate.all
    Reservation.where.not(room_rate_id: nil).each do |reservation|
      room_rate = room_rates.find do |rate|
        rate[:id] == reservation.room_rate_id
      end
      reservation.room_type_id = room_rate.room_type_id
      reservation.rate_plan_id = room_rate.rate_plan_id
      reservation.save(validate: false)
    end
    remove_reference :reservations, :room_rate, foreign_key: { on_delete: :nullify }
  end
end
