# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'
#
# studentscourse1 = []
# studentscourse2 = []
# studentscourse3 = []
# 10.times do
#   studentscourse1 << User.create(name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password)
# end
# 10.times do
#   studentscourse2 << User.create(name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password)
# end
# 10.times do
#   studentscourse3 << User.create(name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password)
# end
# courses = []
#
# 3.times do
#   courses << Course.create(name: Faker::TwinPeaks.location)
# end
#
# courses[0].students << studentscourse1
# courses[1].students << studentscourse2
# courses[2].students << studentscourse3
# courses[0].tas
#

ta = User.create(name: Faker::Name.name, email:'ta@autograder.com', password: '123456')
professor = User.create(name: Faker::Name.name, email: 'prof@autograder.com', password: '123456')
student = User.create(name: Faker::Name.name, email: 'student@autograder.com', password: '123456')

course = Courses.create(name: Faker::TwinPeaks.location)
course.tas << ta
course.professors << professor
course.students << student
