# frozen_string_literal: true

require 'rails_helper'
require 'common/tee_common'

describe 'tees/edit.html.erb', type: :view do
  include TeeCommon
  it 'should render' do
    course = FactoryBot.create(:course, should_fillin_tees: true)
    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, course.tee('Black'))

    render

    TeeCommon.expect_edit_tee(rendered,
                              course.tees,
                              { tee_color: 'Black',
                                course_name: course.name,
                                tee_slope: '139.0',
                                tee_rating: '71.6' })
  end
  it 'initially  show list of tees' do
    course = FactoryBot.create(:course)
    assign(:course, course)
    assign(:tee, course.tee('Blue'))

    render

    TeeCommon.expect_edit_tee(rendered,
                              course.tees,
                              { tee_color: 'Blue',
                                course_name: course.name,
                                tee_slope: '132.0',
                                tee_rating: '69.5' })
  end
end
