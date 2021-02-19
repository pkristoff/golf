# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

describe 'courses/new.html.erb', type: :view do
  include CourseCommon
  it 'has  readonly fields' do
    assign(:course, Course.new)

    render

    expect_form_fields(
      false,
      Button::Course::CREATE,
      { course_name: '',
        course_address_attributes_street_1: '',
        course_address_attributes_street_2: '',
        course_address_attributes_city: '',
        course_address_attributes_state: '',
        course_address_attributes_zip_code: '27502' }
    )
  end
end
