# frozen_string_literal: true

require 'rails_helper'
require 'common/tee_common'

describe 'tees/index.html.erb', type: :view do
  include TeeCommon

  it 'list of tees' do
    course = FactoryBot.create(:course, name: 'Course1')
    assign(:course, course)
    assign(:tees, course.tees)

    render

    TeeCommon.expect_index_tees(rendered, course, course.sorted_tees, true)
  end

  it 'should show no tees' do
    course = FactoryBot.create(:course, name: 'Course1', should_fillin_tees: false)
    assign(:course, course)
    assign(:tees, course.tees)

    render

    TeeCommon.expect_index_tees(rendered, course, course.sorted_tees, true)
  end

  it 'should show no holes' do
    course = FactoryBot.create(:course, name: 'Course1', should_fillin_holes: false)
    assign(:course, course)
    assign(:tees, course.tees)

    render

    TeeCommon.expect_index_tees(rendered, course, course.sorted_tees, true)
  end
end
