# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

describe 'courses/new.html.erb', type: :view do
  include CourseCommon
  it 'has readonly fields' do
    course = Course.new
    assign(:course, course)

    render

    CourseCommon.expect_new_course(
      rendered,
      { course_name: '',
        number_of_holes: 18,
        street1: '',
        street2: '',
        city: '',
        state: '',
        zip_code: '27502' }
    )
  end
end
