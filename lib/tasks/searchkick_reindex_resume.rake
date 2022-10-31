namespace :searchkick do
  desc "reindex without running out of memory?"
  task :altindex, [:start_index, :new_index_name, :batch_size] => :environment do |t, args|
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    count = Lodging.count
    start = args[:start_index].to_i || 0
    batch_size = (args[:batch_size] || 100).to_i

    if args[:new_index_name]
      new_index = Searchkick::Index.new(args[:new_index_name])
      puts "Took an existing index"
    else
      new_index = Lodging.searchkick_index.create_index
      puts "the new created index name is: #{new_index.name}"
    end

    puts "-->>Starting reindex at #{start} with batch size of #{batch_size}..."
    Lodging.find_in_batches(:start=> start, :batch_size=> batch_size).with_index do |batch, index|
      puts "Processing batch ##{index}; total #{index*batch_size+batch_size} Lodgings"
      before = Time.now
      new_index.import(batch)
      time = Time.now - before
      puts "-->>>>>>Processed #{batch_size} Lodgings in #{time} secs"
    end
    Lodging.searchkick_index.swap(new_index.name)
  end

  task :reindex_all, [:batch_size] do |t, args|
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    puts "Reindexing Lodging"
    Rake::Task['searchkick:altindex'].invoke(nil, nil, args[:batch_size])
    puts "Reindexing Region"
    Region.reindex
    puts "Reindexing Country"
    Country.reindex
    puts "Reindexing Price"
    Price.reindex
    puts "Reindexing Experience"
    Experience.reindex
    puts "Reindexing Campaign"
    Campaign.reindex
    puts "Reindexing Place"
    Place.reindex
  end
end
