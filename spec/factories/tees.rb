FactoryBot.define do
  factory :tee do
    color { 'black' }
    rating  { 60.7 }
    slope  { 62.9 }
    after(:build) do |tee, evaluator|
      course = Course.new(name: 'Factory-bot for Tee')
      tee.course=course
      tee.add_18_holes
    end
  end
end