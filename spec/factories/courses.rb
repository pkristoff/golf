# frozen_string_literal: true

# create Course for spec

FactoryBot.define do
  factory :course do
    transient do
      should_fillin_tees { true }
      should_fillin_holes { true }
      hole_info { nil }
    end
    name { 'George' }
    number_of_holes { 18 }
    after(:build) do |course|
      address = course.address
      address.street1 = '555 Xxx Ave.'
      address.street2 = '<nothing>'
      address.city = 'Clarksville'
      address.state = 'IN'
      address.zip_code = '47529'
    end

    after(:create) do |course, evaluator|
      if evaluator.should_fillin_tees
        hole_info = evaluator.hole_info
        case course.number_of_holes
        when 18
          hole_info = TeeHoleInfo::HOLE_INFO_LOCHMERE if evaluator.hole_info.nil?
          course.add_tee(nil, 'Black', 139, 71.6, evaluator.should_fillin_holes ? hole_info[:Black] : [])
          course.add_tee(nil, 'Blue', 132, 69.5, evaluator.should_fillin_holes ? hole_info[:Blue] : [])
          course.add_tee(nil, 'White', 123, 67.1, evaluator.should_fillin_holes ? hole_info[:White] : [])
          course.add_tee(nil, 'Red', 106, 63.6, evaluator.should_fillin_holes ? hole_info[:Red] : [])
        when 9
          hole_info = TeeHoleInfo::HOLE_INFO_KN_1_9 if evaluator.hole_info.nil?
          course.add_tee(nil, 'Black', 113, 27.0, evaluator.should_fillin_holes ? hole_info[:Black] : [])
          course.add_tee(nil, 'Blue', 113, 26.0, evaluator.should_fillin_holes ? hole_info[:Blue] : [])
          course.add_tee(nil, 'White', 113, 25.0, evaluator.should_fillin_holes ? hole_info[:White] : [])
        else
          raise("Unknown number of holes: #{course.number_of_holes}")
        end
      end
    end
  end
end
