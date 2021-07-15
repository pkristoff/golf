# frozen_string_literal: true

require 'rails_helper'
require 'common/hole_common'

describe 'holes/edit.html.erb', type: :view do
  include HoleCommon
  it 'edits first hole' do
    course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
    assign(:course, course)
    assign(:form_disabled, false)
    tee = course.tees.first
    assign(:tee, tee)
    assign(:hole, tee.sorted_holes.first)

    render

    HoleCommon.expect_edit_hole(rendered,
                                tee,
                                { course_name: 'George',
                                  tee_color: 'Black',
                                  hole_number: 1,
                                  yardage: 411,
                                  par: 4,
                                  hdcp: 9,
                                  total_out_yardage: 3366,
                                  total_in_yardage: 3261,
                                  total_yardage: 6627 })
  end
  it 'edits 3rd hole' do
    course = FactoryBot.create(:course)
    assign(:course, course)
    tee = course.tee('Blue')
    assign(:tee, tee)
    assign(:hole, tee.sorted_holes.third)

    render

    HoleCommon.expect_edit_hole(rendered,
                                tee,
                                { course_name: 'George',
                                  tee_color: 'Blue',
                                  hole_number: 3,
                                  yardage: 179,
                                  par: 3,
                                  hdcp: 11,
                                  total_out_yardage: 3106,
                                  total_in_yardage: 3030,
                                  total_yardage: 6136 })
  end
end
