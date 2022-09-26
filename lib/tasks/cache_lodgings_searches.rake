desc "Cache Lodgings Searches(V2::SearchLodgings OR Cumulative Prices)"
task cache_lodgings_searches: :environment do |t, args|
  ActiveRecord::Base.logger = Logger.new(STDOUT)
    puts "Lodgings Cache Started"
    CacheLodgingsJob.perform_later
    puts "Lodgings Cache Ended"
end
