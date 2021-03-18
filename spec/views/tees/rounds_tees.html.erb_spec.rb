# frozen_string_literal: true

require 'rails_helper'
require 'common/rounds_common'

describe 'tees/rounds_tees.html.erb', type: :view do
  include RoundsCommon
  it 'list of courses' do
    course1 = FactoryBot.create(:course, name: 'Course1')
    FactoryBot.create(:course, name: 'Course2')
    assign(:course, course1)
    assign(:tees, course1.sorted_tees)

    render

    expect_rounds_tees(course1, course1.sorted_tees)
  end
end
