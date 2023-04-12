
namespace :searchkick do
  desc "reindex all models"
  task reindexing: :environment  do |t, args|
    Searchkick.load_model('Place')
    Searchkick.models.each do |model|
      puts "Reindexing #{model.name}... at #{DateTime.now.strftime('%d-%m-%Y-%T')}"
      ['campaign', 'place'].include? model.name.downcase ? model.all.map(&:reindex) : model.reindex
    end
    puts "Reindex complete"
  end
end
