desc "Update reservation's status from in cart to expired"
task update_expired_reservations: :environment do |t, args|
  reservations = Reservation.in_cart.where(expired_at: Date.today)

  reservations.each do |reservation|
    if reservation.pending? && (reservation.prebooking? || reservation.option?)
      puts "Reservation id: #{reservation.id}"
      reservation.expired!
    end
  end

  puts "#{Date.today}: Expired reservations are updated successfully!!!"
end
