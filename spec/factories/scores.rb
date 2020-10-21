# frozen_string_literal: true

require 'support/tee_hole_info'

FactoryBot.define do
  factory :score do
    transient do
      round { nil }
    end
    strokes { 4 }
    putts { 2 }
    hole_number { 1 }

    after(:create) do |score, evaluator|
      score.round = FactoryBot.create(:round) if evaluator.round.nil?
      score.round = evaluator.round unless evaluator.round.nil?
    end
  end
end
