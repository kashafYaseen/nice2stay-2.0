desc "Sync prevoius lodgings with categories"
task sync_lodging_categories: :environment do |t, args|
  Lodging.where(lodging_category_id: nil).each do |lodging|
    lodging.update(lodging_category_id: LodgingCategory.find_by(name: lodging.lodging_type)&.id)
    puts "Lodging Updation Done ----------------->> #{lodging.id}"
  end
  puts "--------------------------------Done--------------------------------"
end
