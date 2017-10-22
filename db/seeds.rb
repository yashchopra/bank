# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(email:"yash_admin@yash.coem", password: "Yashyash1.", role:"admin")
User.create(email:"yash_tier1@yash.com", password: "Yashyash1.", role:"tier1")
User.create(email:"yash_tier2@yash.com", password: "Yashyash1.", role:"tier2")
User.create(email:"yash_customer@yash.com", password: "Yashyash1.", role:"customer")
User.create(email:"yash_organization@yash.com", password: "Yashyash1.", role:"organization")