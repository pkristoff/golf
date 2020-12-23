# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :course do
    name { 'George' }
    after(:create) do |course|
      course.address.street_1 = '555 Xxx Ave.'
      course.address.street_2 = '<nothing>'
      course.address.city = 'Clarksville'
      course.address.state = 'IN'
      course.address.zip_code = '47529'

      course.add_tee(nil, 'Black', 71.6, 139, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
      course.add_tee(nil, 'Blue', 69.5, 132, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
      course.add_tee(nil, 'White', 67.1, 123, TeeHoleInfo::HOLE_INFO_LOCHMERE[:White])
      course.add_tee(nil, 'Red', 63.6, 106, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Red])
    end
  end
end
