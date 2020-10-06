# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :course do
    name { 'George' }
    after(:build) do |course|
      course.address.street_1 = '555 Xxx Ave.'
      course.address.street_2 = '<nothing>'
      course.address.city = 'Clarksville'
      course.address.state = 'IN'
      course.address.zip_code = '47529'

      course.add_tee('Black', 71.6, 139, TeeHoleInfo::BLACK_HOLE_INFO)
      course.add_tee('Blue', 69.5, 132, TeeHoleInfo::BLUE_HOLE_INFO)
      course.add_tee('White', 67.1, 123, TeeHoleInfo::WHITE_HOLE_INFO)
      course.add_tee('Red', 63.6, 106, TeeHoleInfo::RED_HOLE_INFO)
    end
  end
end
