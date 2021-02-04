# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :course do
    transient do
      should_fillin_tees { true }
      should_fillin_holes { true }
    end
    name { 'George' }
    after(:build) do |course|
      address = course.address
      address.street_1 = '555 Xxx Ave.'
      address.street_2 = '<nothing>'
      address.city = 'Clarksville'
      address.state = 'IN'
      address.zip_code = '47529'
    end
    after(:create) do |course, evaluator|
      if evaluator.should_fillin_tees
        course.add_tee(nil, 'Black', 71.6, 139, evaluator.should_fillin_holes ? TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black] : [])
        course.add_tee(nil, 'Blue', 69.5, 132, evaluator.should_fillin_holes ? TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue] : [])
        course.add_tee(nil, 'White', 67.1, 123, evaluator.should_fillin_holes ? TeeHoleInfo::HOLE_INFO_LOCHMERE[:White] : [])
        course.add_tee(nil, 'Red', 63.6, 106, evaluator.should_fillin_holes ? TeeHoleInfo::HOLE_INFO_LOCHMERE[:Red] : [])
      end
    end
  end
end
