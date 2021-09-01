desc "Remove duplicate availabilities"
task remove_duplicate_availabilities: :environment do |t, args|
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  loop do
    duplicate_ids = Availability.group(:lodging_id, :available_on).select("lodging_id, available_on, MIN(id) as id").having("COUNT(*) > 1").map(&:id)
    break if duplicate_ids.count == 0
    duplicate_ids.slice(1000).each do |ids|
      puts "Remove availabilities"
      Availability.where.not(id: ids).delete_all
      puts "Remove prices"
      Price.where(availability_id: ids).delete_all
    end
  end
  Lodging.reindex
  Lodging.flush_cached_searched_data
  Price.reindex
end
