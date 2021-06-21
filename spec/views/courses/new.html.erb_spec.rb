# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

describe 'courses/new.html.erb', type: :view do
  include CourseCommon
  it 'has  readonly fields' do
    assign(:course, Course.new)

    render

    CourseCommon.expect_form_fields(
      rendered,
      false,
      Button::Course::CREATE,
      { course_name: '',
        number_of_holes: 18,
        street_1: '',
        street_2: '',
        city: '',
        state: '',
        zip_code: '27502' }
    )
  end
end
