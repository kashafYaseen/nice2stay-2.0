desc "Update wishlists to accommodate trips"
task update_wishlists: :environment do |t, args|
  Wishlist.where(trip_id: nil).each do |wishlist|
    next unless wishlist.user.present?
    trip = wishlist.user.trips.first || wishlist.user.trips.create(name: "Trip")
    trip.users << wishlist.user unless trip.users.include?(wishlist.user)
    wishlist.update(trip: trip)
    puts "Add Trip for #{wishlist.user.full_name}"
  end
end
