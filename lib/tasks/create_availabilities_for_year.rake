desc "Create availabilities for specified year in arugment for all accommodations"
task :create_availabilities_for_year, [:year] => :environment do |t, args|
  abort 'Please enter valid year!!!' unless args[:year].present?

  start_date = "01-01-#{args[:year]}".to_date
  end_date = "31-12-#{args[:year]}".to_date

  Lodging.published.each_with_index do |lodging, index|
    next if lodging.availabilities_for_range(start_date, end_date).present?
    lodging.add_availabilities_for (start_date..end_date).map(&:to_s)
    puts "#{index + 1} Availabilities created for #{lodging.name}"
    lodging.reindex
  end
  Lodging.flush_cached_searched_data

  puts "Availabilities created successfully!!!"
end

