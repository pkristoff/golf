# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :tee do
    color { 'black' }
    rating { 60.7 }
    slope { 62.9 }
    after(:build) do |tee, _evaluator|
      course = Course.new(name: 'Factory-bot for Tee')
      tee.course = course
      tee.add_18_holes
      (1..18).each do |i|
        hole = tee.hole(i)
        hole.yardage = 350
        hole.par = 4
        hole.hdcp = 9
      end
    end
  end
end
