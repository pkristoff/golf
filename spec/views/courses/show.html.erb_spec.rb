# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

describe 'courses/show.html.erb', type: :view do
  include CourseCommon
  it 'has  readonly fields' do
    course = FactoryBot.create(:course)
    assign(:course, course)

    render

    CourseCommon.expect_show_fields_with_values(
      rendered,
      course.tees,
      { course_name: 'George',
        number_of_holes: 18,
        street_1: '555 Xxx Ave.',
        street_2: '<nothing>',
        city: 'Clarksville',
        state: 'IN',
        zip_code: '47529' }
    )
  end
end
