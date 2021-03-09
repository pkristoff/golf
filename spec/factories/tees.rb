# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :tee do
    transient do
      tee_hole_info { nil }
    end
    color { 'black' }
    rating { 60.7 }
    slope { 62.9 }
    course { Course.create(name: 'Factory-bot for Tee') }
    after(:create) do |tee, evaluator|
      hole_info = evaluator.tee_hole_info
      if hole_info
        tee.course.number_of_holes = hole_info.size == 10 ? 9 : 18
        tee.course.add_tee(tee, tee.color, tee.rating, tee.slope, evaluator.tee_hole_info)
      else
        tee.course.number_of_holes = 18
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
end
