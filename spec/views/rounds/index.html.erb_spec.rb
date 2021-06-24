# frozen_string_literal: true

require 'rails_helper'
require 'common/rounds_common'

describe 'rounds/index.html.erb', type: :view do
  include RoundsCommon
  it 'no rounds' do
    course1 = FactoryBot.create(:course, name: 'Course1')
    assign(:course, course1)
    course_tee = course1.tee('Black')
    assign(:tee, course_tee)

    render

    RoundsCommon.expect_rounds_index(rendered, course1, course_tee, course_tee.rounds, false)
  end

  it 'show rounds' do
    round = FactoryBot.create(:round)
    course_tee = round.tee
    assign(:tee, course_tee)
    course = course_tee.course
    assign(:course, course)

    render

    RoundsCommon.expect_rounds_index(rendered, course, course_tee, course_tee.rounds, false)
  end
end
