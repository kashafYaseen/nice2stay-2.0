# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

Lodging.destroy_all

Region.find_or_create_region('America', 'Florida')
Owner.find_or_create_by(email: 'owner@mail.com', password: 'password')

CSV.foreach("db/Sacramentorealestatelodgings.csv", headers: true) do |line|
  Lodging.create! line.to_hash.except(*%w{type latitude longitude}).merge({ region_id: Region.first.id, owner_id: Owner.first.id })
end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
