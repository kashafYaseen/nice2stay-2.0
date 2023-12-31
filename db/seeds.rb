# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# require 'csv'

# Lodging.destroy_all

# region = Region.find_or_create_region('America', 'Florida')
# owner = Owner.find_by(email: 'owner@mail.com')
# owner = Owner.create(email: 'owner@mail.com', password: 'password') unless owner.present?

# CSV.foreach("db/Sacramentorealestatelodgings.csv", headers: true) do |line|
#   Lodging.create! line.to_hash.except(*%w{type latitude longitude}).merge({ region_id: region.id, owner_id: owner.id })
# end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
