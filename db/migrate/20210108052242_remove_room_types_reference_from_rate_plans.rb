class RemoveRoomTypesReferenceFromRatePlans < ActiveRecord::Migration[5.2]
  def up
    RatePlan.all.each do |rate_plan|
      room_rate = RoomRate.find_or_initialize_by(room_type_id: rate_plan.room_type_id, rate_plan_id: rate_plan.id)
      room_rate.save(validate: false)
    end
    remove_reference :rate_plans, :room_type, foreign_key: { on_delete: :cascade }
  end

  def down
    add_reference :rate_plans, :room_type, foreign_key: { on_delete: :cascade }
    room_rates = RoomRate.all
    RatePlan.all.each do |rate_plan|
      room_rate = room_rates.find do |rate|
        rate[:rate_plan_id] == rate_plan.id
      end
      rate_plan.room_type_id = room_rate.room_type_id
      rate_plan.save(validate: false)
    end
  end
end
