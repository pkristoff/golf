# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :tee do
    transient do
      tee_hole_info { nil }
    end
    color { 'Black' }
    rating { 72 }
    slope { 113 }
    course do
      FactoryBot.create(:course, name: 'for factorybot tee', should_fillin_tees: false)
    end
    after(:create) do |tee, evaluator|
      hole_info = evaluator.tee_hole_info
      if hole_info
        tee.course.number_of_holes = hole_info.size == 10 ? 9 : 18
        tee.course.add_tee(tee, tee.color, tee.slope, tee.rating, evaluator.tee_hole_info)
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
