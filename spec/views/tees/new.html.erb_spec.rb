# frozen_string_literal: true

require 'rails_helper'
require 'common/tee_common'

describe 'tees/new.html.erb', type: :view do
  include TeeCommon
  it 'has  readonly fields' do
    course = FactoryBot.create(:course, should_fillin_tees: false)
    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, Tee.new)

    render

    expect_tee_form_fields(
      rendered,
      course.tees,
      { color: '',
        slope: '',
        rating: '',
        number_of_holes: '18' },
      'Create'
    )
  end
  it 'initially  show list of tees' do
    course = FactoryBot.create(:course)
    assign(:course, course)
    assign(:tee, Tee.new)

    render

    expect_tee_form_fields(
      rendered,
      course.tees,
      { color: '',
        slope: '',
        rating: '',
        number_of_holes: '18' },
      'Create'
    )
  end
end
