# frozen_string_literal: true

require 'rails_helper'
require 'common/course_common'

RSpec.describe 'courses/index.html.erb', type: :view do
  include CourseCommon
  it 'index with zero course' do
    assign(:courses, [])

    render

    CourseCommon.expect_course_index(rendered, [])
  end

  it 'index with one course' do
    course = FactoryBot.create(:course)
    assign(:courses, [course])

    render

    CourseCommon.expect_course_index(rendered, [course])
  end
end
