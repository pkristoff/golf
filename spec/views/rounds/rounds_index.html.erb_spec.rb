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

    expect_rounds(rendered, course1, course_tee, course_tee.rounds, true)
  end
  it 'show rounds' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course
    assign(:course, course)
    assign(:tee, tee)

    render

    expect_rounds(rendered, course, tee, tee.rounds, true)
  end
end
