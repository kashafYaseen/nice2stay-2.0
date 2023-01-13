
namespace :searchkick do
  desc "reindex all models"
  task reindexing: :environment  do |t, args|
    Searchkick.models.each do |model|
      puts "Reindexing #{model.name}..."
      model.name.downcase == 'campaign' ? model.all.map(&:reindex) : model.reindex
    end
    puts "Reindex complete"
  end
end
