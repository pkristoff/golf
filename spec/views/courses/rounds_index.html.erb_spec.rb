# frozen_string_literal: true

require 'rails_helper'
require 'common/rounds_common'

describe 'courses/rounds_index.html.erb', type: :view do
  include RoundsCommon
  it 'list of courses' do
    FactoryBot.create(:course, name: 'Course1')
    FactoryBot.create(:course, name: 'Course2')
    assign(:courses, Course.all)

    render

    expect_rounds_index(rendered, Course.all)
  end
end
