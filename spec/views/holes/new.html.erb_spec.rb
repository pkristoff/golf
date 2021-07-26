# frozen_string_literal: true

require 'rails_helper'
require 'common/hole_common'

describe 'holes/new.html.erb', type: :view do
  include HoleCommon
  it 'has  no holes for tee' do
    course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: false)
    assign(:course, course)
    assign(:form_disabled, false)
    tee = course.tees.first
    assign(:tee, tee)
    assign(:hole, Hole.new)

    render

    HoleCommon.expect_new_hole(rendered,
                               course,
                               tee,
                               { course_name: 'George',
                                 tee_color: 'Black',
                                 hole_number: 0,
                                 yardage: 0,
                                 par: 0,
                                 hdcp: 0,
                                 total_out_yardage: 0,
                                 total_in_yardage: 0,
                                 total_yardage: 0 })
  end
  it 'has sorted holes for tee' do
    course = FactoryBot.create(:course)
    assign(:course, course)
    assign(:tee, course.tees.first)
    assign(:hole, Hole.new(number: 1, yardage: 234, par: 3, hdcp: 9))

    render

    HoleCommon.expect_new_hole(rendered,
                               course,
                               course.tees.first,
                               { course_name: 'George',
                                 tee_color: 'Black',
                                 hole_number: 1,
                                 yardage: 234,
                                 par: 3,
                                 hdcp: 9,
                                 total_out_yardage: 3366,
                                 total_in_yardage: 3261,
                                 total_yardage: 6627 })
  end
end
