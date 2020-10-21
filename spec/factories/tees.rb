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
    after(:build) do |tee, evaluator|
      course = Course.new(name: 'Factory-bot for Tee')
      tee.course = course
      if evaluator.tee_hole_info
        course.add_tee(tee.color, tee.rating, tee.slope, evaluator.tee_hole_info)
      else
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
