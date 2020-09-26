FactoryBot.define do
  factory :course do
    name { 'George' }
    after(:build) do |course|
      course.address.street_1 = '555 Xxx Ave.'
      course.address.street_2 = '<nothing>'
      course.address.city = 'Clarksville'
      course.address.state = 'IN'
      course.address.zip_code = '47529'

      course.add_tee('Black', 71.6, 139, 18)
      course.add_tee('Blue', 69.5, 132, 18)
      course.add_tee('White', 67.1, 123, 18)
      course.add_tee('Red', 63.6, 106, 18)
    end
  end
end