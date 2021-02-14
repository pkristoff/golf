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

    expect(rendered).to have_selector('h1', count: 1, text: 'New hole:')
    expect(rendered).to have_selector('h2', count: 1, text: 'Course: George')
    expect(rendered).to have_selector('h2', count: 1, text: 'Tee: Black')

    expect_hole_form_fields(
      rendered,
      tee.sorted_holes,
      'Create',
      { number: 0,
        yardage: 0,
        par: 0,
        hdcp: 0 }
    )
  end
  it 'has sorted holes for tee' do
    course = FactoryBot.create(:course)
    assign(:course, course)
    assign(:tee, course.tees.first)
    assign(:hole, Hole.new(number: 1, yardage: 234, par: 3, hdcp: 9))

    render

    expect_hole_form_fields(
      rendered,
      course.tees.first.holes,
      'Create',
      { number: 1,
        yardage: 234,
        par: 3,
        hdcp: 9 }
    )
  end
end
