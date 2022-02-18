# frozen_string_literal: true

# create Course for spec
#

FactoryBot.define do
  factory :account do
    name { 'Paul' }
    handicap_index { 0.0 }

    after(:build) do |account|
    end
    after(:create) do |account, evaluator|
    end
  end
end
