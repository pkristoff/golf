# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

describe 'courses/show.html.erb', type: :view do
  include CourseCommon
  it 'has  readonly fields' do
    course = FactoryBot.create(:course)
    assign(:course, course)

    render

    expect_form_fields(
      true,
      Button::Course::UPDATE,
      { course_name: 'George',
        course_address_attributes_street_1: '555 Xxx Ave.',
        course_address_attributes_street_2: '<nothing>',
        course_address_attributes_city: 'Clarksville',
        course_address_attributes_state: 'IN',
        course_address_attributes_zip_code: '47529' }
    )
  end
end
