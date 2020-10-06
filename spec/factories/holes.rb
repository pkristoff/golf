# frozen_string_literal: true

# create Course for spec
#
require 'support/tee_hole_info'

FactoryBot.define do
  factory :hole do
    number { 1 }
    par  { 4 }
    hdcp { 18 }
  end
end
