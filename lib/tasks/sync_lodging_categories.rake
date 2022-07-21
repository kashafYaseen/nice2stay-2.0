desc "Sync prevoius lodgings with categories"
task sync_lodging_categories: :environment do |t, args|
  Lodging.where(lodging_category_id: nil).each do |l|
    l.update(lodging_category_id: LodgingCategory.find_by(name: l.lodging_type)&.id)
    puts "Lodging Updation Done ----------------->> #{l.id}"
  end
  puts "--------------------------------Done--------------------------------"
end
